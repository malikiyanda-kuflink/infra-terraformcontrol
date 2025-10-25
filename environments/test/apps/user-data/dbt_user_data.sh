#!/bin/bash
set -euo pipefail

# ========= Config (Terraform can inject REGION/ENV_NAME via templatefile) =========
REGION="${REGION:-eu-west-2}"
ENV_NAME="${ENV_NAME:-staging}"
# ================================================================================

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a "$LOG_FILE") 2>&1

USERNAME="${USERNAME:-ubuntu}"
SSH_DIR="/home/${USERNAME}/.ssh"
AUTHORIZED_KEYS="${SSH_DIR}/authorized_keys"
PRESERVE_EXISTING_AUTH_KEYS="${PRESERVE_EXISTING_AUTH_KEYS:-true}"

PUBLIC_KEY_PARAMS=(
  "/kuflink/ssh/public-keys/ArchitectPublicKey"
  "/kuflink/ssh/public-keys/DevOpsPublicKey"
  "/kuflink/ssh/public-keys/TeamLeadPublicKey"
  "/kuflink/ssh/public-keys/TechLeadPublicKey"
)

DBT_BASE_DIR="/opt/dbt"
DBT_PROJECT_DIR="${DBT_BASE_DIR}/project"
DBT_RUNTIME_DIR="${DBT_BASE_DIR}/runtime"
DBT_ENV_FILE="${DBT_BASE_DIR}/.env"
DBT_PROFILES_FILE="${DBT_RUNTIME_DIR}/profiles.yml"

DBT_PROFILE_NAME="${DBT_PROFILE_NAME:-carl}"
DBT_TARGET_NAME="${DBT_TARGET_NAME:-dev}"

# CloudWatch config destination
CW_CONFIG_DST="/opt/aws/amazon-cloudwatch-agent/bin/config.json"

log() { echo "[$(date +'%F %T')] $*"; }

########################################
# Helpers: metadata, namespace, sanity
########################################
fetch_instance_identity() {
  log "🔎 Fetching instance metadata / tags..."
  # IMDSv2 token
  TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

  INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
    http://169.254.169.254/latest/meta-data/instance-id)

  # Get Name tag via EC2 API (needs instance profile perms: ec2:DescribeTags or ec2:DescribeInstances)
  INSTANCE_NAME=$(aws ec2 describe-tags \
    --region "$REGION" \
    --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=Name" \
    --query "Tags[0].Value" \
    --output text 2>/dev/null || echo "UnknownInstance")

  # We'll use this to build CloudWatch namespace:
  #   CWAgent-<Name>-Limited
  # If the Name tag has spaces or weird chars, normalize a bit
  SAFE_INSTANCE_NAME=$(echo "${INSTANCE_NAME}" | tr ' /:' '---')
  CW_NAMESPACE="CWAgent-${SAFE_INSTANCE_NAME}-Limited"

  export INSTANCE_ID INSTANCE_NAME SAFE_INSTANCE_NAME CW_NAMESPACE
  log "ℹ️  INSTANCE_ID=${INSTANCE_ID}"
  log "ℹ️  INSTANCE_NAME=${INSTANCE_NAME}"
  log "ℹ️  CW_NAMESPACE=${CW_NAMESPACE}"
}

########################################
# SSH access bootstrap
########################################
configure_ssh_keys_from_ssm() {
  log "🔑 Installing SSH keys from SSM..."
  mkdir -p "$SSH_DIR"
  chown "$USERNAME:$USERNAME" "$SSH_DIR"
  chmod 700 "$SSH_DIR"

  : > "${AUTHORIZED_KEYS}.tmp"

  if [[ -f "$AUTHORIZED_KEYS" && "$PRESERVE_EXISTING_AUTH_KEYS" == "true" ]]; then
    tr '\r' '\n' < "$AUTHORIZED_KEYS" | sed '/^[[:space:]]*$/d' >> "${AUTHORIZED_KEYS}.tmp"
  fi

  for param in "${PUBLIC_KEY_PARAMS[@]}"; do
    val="$(aws ssm get-parameter \
      --name "$param" \
      --with-decryption \
      --region "$REGION" \
      --query 'Parameter.Value' \
      --output text 2>/dev/null || true)"

    if [[ -n "$val" && "$val" != "None" ]] && echo "$val" | grep -Eq '^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp256) '; then
      echo "$val" >> "${AUTHORIZED_KEYS}.tmp"
      log "   ➕ Installed key from $param"
    else
      log "   ⚠️  Key missing/invalid: $param"
    fi
  done

  if [[ -s "${AUTHORIZED_KEYS}.tmp" ]]; then
    sort -u "${AUTHORIZED_KEYS}.tmp" > "$AUTHORIZED_KEYS"
    rm -f "${AUTHORIZED_KEYS}.tmp"
    chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    log "✅ Installed $(wc -l < "$AUTHORIZED_KEYS") SSH keys"
  else
    rm -f "${AUTHORIZED_KEYS}.tmp" || true
    log "⚠️  No SSH keys written"
  fi
}

########################################
# Base utils, Docker, CodeDeploy agent
########################################
install_base_utils() {
  log "📦 Installing base utils (AWS CLI, git, Docker deps, netcat, etc.)..."
  apt-get update -y
  apt-get install -y \
    awscli git ca-certificates curl gnupg lsb-release netcat \
    unzip jq collectd

  # Docker repo setup
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  systemctl enable --now docker
  usermod -aG docker "$USERNAME" || true

  log "✅ AWS CLI / git / docker / compose installed"
}

install_codedeploy_agent() {
  log "🚀 Installing AWS CodeDeploy Agent..."
  apt-get install -y ruby-full wget

  cd /tmp
  wget "https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install"
  chmod +x ./install
  ./install auto || true

  systemctl enable codedeploy-agent || true
  systemctl start codedeploy-agent || true

  if systemctl is-active --quiet codedeploy-agent; then
    log "✅ CodeDeploy agent running"
  else
    log "❌ CodeDeploy agent not active"
    systemctl status codedeploy-agent --no-pager || true
  fi

  rm -f /tmp/install
}

########################################
# DBT secrets + runtime prep
########################################
# map env_name like "staging", "test", "production"
normalize_env_name() {
  local input="${ENV_NAME:-staging}"
  case "${input,,}" in
    prod|production)   ENV_NAME="production" ;;
    stage|staging|stg) ENV_NAME="staging" ;;
    test|testing|tst)  ENV_NAME="test" ;;
    *)
      log "[ERROR] ENV_NAME '${input}' invalid. Use: test | staging | production"
      exit 1
      ;;
  esac
  log "[INFO] Using ENV_NAME='${ENV_NAME}'"
}

# define SSM param paths for Redshift after ENV_NAME is finalized
set_redshift_param_paths() {
  SSM_RS_HOST="/backend/${ENV_NAME}/REDSHIFT_HOST"
  SSM_RS_DB="/backend/${ENV_NAME}/REDSHIFT_DATABASE"
  SSM_RS_USER="/backend/${ENV_NAME}/REDSHIFT_USERNAME"
  SSM_RS_PASS="/backend/${ENV_NAME}/REDSHIFT_PASSWORD"
  SSM_RS_PORT="/backend/${ENV_NAME}/REDSHIFT_PORT"
}

fetch_redshift_secrets_to_envfile() {
  log "🔐 Fetching Redshift credentials from SSM (${ENV_NAME})..."
  RS_HOST=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_HOST" --query 'Parameter.Value' --output text)
  RS_DB=$(aws ssm get-parameter   --with-decryption --region "$REGION" --name "$SSM_RS_DB"   --query 'Parameter.Value' --output text)
  RS_USER=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_USER" --query 'Parameter.Value' --output text)
  RS_PASS=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_PASS" --query 'Parameter.Value' --output text)
  RS_PORT=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_PORT" --query 'Parameter.Value' --output text)

  mkdir -p "$DBT_BASE_DIR"
  cat > "$DBT_ENV_FILE" <<EOF
DBT_RS_HOST=${RS_HOST}
DBT_RS_DB=${RS_DB}
DBT_RS_USER=${RS_USER}
DBT_RS_PASS=${RS_PASS}
DBT_RS_PORT=${RS_PORT}
DBT_RS_SCHEMA=analytics
EOF
  chown "$USERNAME:$USERNAME" "$DBT_ENV_FILE"
  chmod 600 "$DBT_ENV_FILE"
  log "✅ Wrote ${DBT_ENV_FILE}"
}

write_runtime_profiles_yaml() {
  log "📝 Writing DBT profiles.yml..."
  mkdir -p "$DBT_RUNTIME_DIR"
  cat > "$DBT_PROFILES_FILE" <<YAML
${DBT_PROFILE_NAME}:
  target: ${DBT_TARGET_NAME}
  outputs:
    ${DBT_TARGET_NAME}:
      type: redshift
      host: "{{ env_var('DBT_RS_HOST') }}"
      port: "{{ env_var('DBT_RS_PORT') | as_number }}"
      dbname: "{{ env_var('DBT_RS_DB') }}"
      schema: "{{ env_var('DBT_RS_SCHEMA') }}"
      user: "{{ env_var('DBT_RS_USER') }}"
      password: "{{ env_var('DBT_RS_PASS') }}"
      threads: 4
      sslmode: prefer
YAML
  chown "$USERNAME:$USERNAME" "$DBT_PROFILES_FILE"
  chmod 640 "$DBT_PROFILES_FILE"
  log "✅ Wrote ${DBT_PROFILES_FILE}"
}

prepare_deployment_directory() {
  log "📁 Preparing deployment directory..."
  mkdir -p "$DBT_PROJECT_DIR"
  chown -R "$USERNAME:$USERNAME" "$DBT_BASE_DIR"
  log "✅ Created ${DBT_PROJECT_DIR} (CodeDeploy will populate this)"
}

install_docs_systemd_service() {
  log "🛠️ Creating systemd service for dbt-docs..."
  cat > /etc/systemd/system/dbt-docs.service <<UNIT
[Unit]
Description=DBT documentation server (Docker Compose)
Wants=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=${DBT_PROJECT_DIR}
ExecStart=/usr/bin/docker compose up -d docs
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

  systemctl daemon-reload
  systemctl enable dbt-docs.service
  log "✅ dbt-docs.service created and enabled (will start after CodeDeploy deploys project)"
}

########################################
# Monitoring stack (CloudWatch / SSM / collectd)
########################################
install_monitoring_stack() {
  log "📈 Installing monitoring stack (CloudWatch Agent, SSM Agent, collectd)..."

  # CloudWatch Agent
  if ! command -v /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl >/dev/null 2>&1; then
    log "⬇️ Installing CloudWatch Agent .deb"
    wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb
    dpkg -i /tmp/amazon-cloudwatch-agent.deb
  else
    log "✅ CloudWatch Agent already present"
  fi

  # SSM Agent
  if ! systemctl is-active --quiet snap.amazon-ssm-agent.amazon-ssm-agent; then
    snap install amazon-ssm-agent --classic || true
    systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent || true
  fi

  # collectd - ONLY enable uptime plugin to minimize metrics
  apt-get install -y collectd || true

  if [ -f /etc/collectd/collectd.conf ]; then
    log "📝 Configuring collectd for uptime only (cost optimization)..."
    
    # Backup original config
    cp /etc/collectd/collectd.conf /etc/collectd/collectd.conf.bak || true
    
    # Create minimal config with only uptime and network plugins
    cat > /etc/collectd/collectd.conf <<'COLLECTD_EOF'
# Minimal collectd config - ONLY uptime metric for cost optimization
Hostname "localhost"
FQDNLookup false
Interval 60
Timeout 2
ReadThreads 5

# Load only essential plugins
LoadPlugin logfile
LoadPlugin network
LoadPlugin uptime

<Plugin logfile>
  LogLevel "info"
  File "/var/log/collectd.log"
  Timestamp true
</Plugin>

<Plugin network>
  Server "127.0.0.1" "25826"
</Plugin>

<Plugin uptime>
</Plugin>
COLLECTD_EOF

    log "✅ collectd configured for uptime only"
  fi

  # Fetch CloudWatch config from SSM Parameter Store
  log "🔽 Fetching CloudWatch config from SSM Parameter Store..."
  SSM_CW_CONFIG="/kuflink/dbt/${ENV_NAME}/cloudwatch_config"
  
  mkdir -p "$(dirname "$CW_CONFIG_DST")"
  
  if ! aws ssm get-parameter \
    --name "$SSM_CW_CONFIG" \
    --region "$REGION" \
    --query 'Parameter.Value' \
    --output text > "$CW_CONFIG_DST" 2>/dev/null; then
    log "❌ ERROR: Failed to fetch CloudWatch config from SSM: ${SSM_CW_CONFIG}"
    log "   Ensure the parameter exists and IAM permissions allow ssm:GetParameter"
    exit 1
  fi

  if [[ ! -f "$CW_CONFIG_DST" || ! -s "$CW_CONFIG_DST" ]]; then
    log "❌ ERROR: CloudWatch config file is empty or missing after SSM fetch"
    exit 1
  fi

  log "✅ CloudWatch config fetched from SSM and written to ${CW_CONFIG_DST}"

  # Verify log groups exist (they should be created by Terraform)
  log "📋 Verifying CloudWatch Log Groups exist..."
  
  LOG_GROUPS_EXIST=true
  for log_group in \
    "/ec2/${SAFE_INSTANCE_NAME}/syslog" \
    "/ec2/${SAFE_INSTANCE_NAME}/cloud-init" \
    "/ec2/${SAFE_INSTANCE_NAME}/user-data"
  do
    if aws logs describe-log-groups \
      --log-group-name-prefix "$log_group" \
      --region "$REGION" \
      --query "logGroups[?logGroupName=='${log_group}'].logGroupName" \
      --output text 2>/dev/null | grep -q "^${log_group}$"; then
      log "   ✅ Log group exists: $log_group"
    else
      log "   ⚠️  Log group missing: $log_group (should be created by Terraform)"
      LOG_GROUPS_EXIST=false
    fi
  done
  
  if [[ "$LOG_GROUPS_EXIST" == "false" ]]; then
    log "⚠️  Warning: Some log groups are missing. Logs may not appear in CloudWatch."
    log "   Ensure Terraform creates these log groups before instance launch."
  else
    log "✅ All log groups verified"
  fi

  log "▶ Restarting collectd & starting CloudWatch Agent..."
  systemctl restart collectd || true

  # Stop any existing CloudWatch Agent first
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a stop \
    -m ec2 2>/dev/null || true

  sleep 2

  # Start CloudWatch Agent with config
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:"$CW_CONFIG_DST" \
    -s

  # Wait a moment for services to stabilize
  sleep 3

  CW_STATUS=$(systemctl is-active amazon-cloudwatch-agent || true)
  SSM_STATUS=$(systemctl is-active snap.amazon-ssm-agent.amazon-ssm-agent || true)
  COLLECTD_STATUS=$(systemctl is-active collectd || true)

  if [[ "$CW_STATUS" == "active" && "$SSM_STATUS" == "active" && "$COLLECTD_STATUS" == "active" ]]; then
    log "✅ Monitoring stack healthy"
    echo "OK" > /var/log/instance-health.log
  else
    log "❌ Monitoring stack issue"
    log "   CloudWatch Agent: ${CW_STATUS}"
    log "   SSM Agent: ${SSM_STATUS}"
    log "   collectd: ${COLLECTD_STATUS}"
    
    if [[ "$CW_STATUS" != "active" ]]; then
      log "   CloudWatch Agent errors (last 20 lines):"
      tail -20 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log 2>/dev/null || log "      (no log file found)"
    fi
    
    echo "BAD" > /var/log/instance-health.log
  fi
  
  log ""
  log "📊 Monitoring Configuration:"
  log "   Namespace: ${CW_NAMESPACE}"
  log "   Metrics: ~9 total (cost-optimized)"
  log "   Log Groups:"
  log "     - /ec2/${SAFE_INSTANCE_NAME}/syslog"
  log "     - /ec2/${SAFE_INSTANCE_NAME}/cloud-init"
  log "     - /ec2/${SAFE_INSTANCE_NAME}/user-data"
  log ""
  log "💡 Tip: Logs and metrics may take 1-3 minutes to appear in CloudWatch"
}

########################################
# main()
########################################
main() {
  log "🚀 Starting DBT EC2 setup bootstrap..."

  fetch_instance_identity      # sets INSTANCE_NAME, CW_NAMESPACE, etc
  normalize_env_name
  set_redshift_param_paths

  configure_ssh_keys_from_ssm
  install_base_utils
  install_codedeploy_agent

  fetch_redshift_secrets_to_envfile
  write_runtime_profiles_yaml
  prepare_deployment_directory
  install_docs_systemd_service

  install_monitoring_stack

  log "🎉 EC2 setup complete! Ready for CodeDeploy deployments"
  log "📊 Environment: ${ENV_NAME}"
  log "📁 Deployment dir: ${DBT_PROJECT_DIR}"
  log "🤖 CodeDeploy agent: $(systemctl is-active codedeploy-agent || true)"
  log "📈 CloudWatch namespace: ${CW_NAMESPACE}"
  log ""
  log "Next steps:"
  log "  - CodeDeploy will deploy the DBT project into ${DBT_PROJECT_DIR}"
  log "  - dbt-docs.service will run docker compose 'docs'"
  log "  - Check monitoring in CloudWatch Metrics under ${CW_NAMESPACE}"
  log ""
  log "To check status later:"
  log "  - systemctl status codedeploy-agent"
  log "  - systemctl status dbt-docs.service"
  log "  - docker compose ps   (cd ${DBT_PROJECT_DIR})"
  log "  - systemctl status amazon-cloudwatch-agent collectd snap.amazon-ssm-agent.amazon-ssm-agent"
}

main "$@"