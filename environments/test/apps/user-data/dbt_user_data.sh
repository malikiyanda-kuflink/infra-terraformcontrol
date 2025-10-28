#!/bin/bash
set -euo pipefail

# ========= Config =========
REGION="${REGION:-eu-west-2}"
ENV_NAME="${ENV_NAME:-staging}"

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

CW_CONFIG_DST="/opt/aws/amazon-cloudwatch-agent/bin/config.json"

log() { echo "[$(date +'%F %T')] $*"; }

########################################
# Metadata & Identity
########################################
fetch_instance_identity() {
  log "🔎 Fetching instance metadata / tags..."
  
  # Get IMDSv2 token
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  
  # Get instance ID
  if [[ -n "$TOKEN" ]]; then
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)
  else
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  fi

  if [[ -z "$INSTANCE_ID" ]]; then
    INSTANCE_ID="unknown"
    INSTANCE_NAME="UnknownInstance"
  else
    log "✅ Instance ID: ${INSTANCE_ID}"
    
    # Get Name tag from metadata service (no AWS CLI needed!)
    if [[ -n "$TOKEN" ]]; then
      INSTANCE_NAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
        http://169.254.169.254/latest/meta-data/tags/instance/Name 2>/dev/null || echo "")
    else
      INSTANCE_NAME=$(curl -s \
        http://169.254.169.254/latest/meta-data/tags/instance/Name 2>/dev/null || echo "")
    fi
    
    if [[ -z "$INSTANCE_NAME" || "$INSTANCE_NAME" == "Not Found" ]]; then
      INSTANCE_NAME="DBT-${INSTANCE_ID}"
      log "⚠️  Using fallback name: ${INSTANCE_NAME}"
    else
      log "✅ Found Name tag: ${INSTANCE_NAME}"
    fi
  fi

  SAFE_INSTANCE_NAME=$(echo "${INSTANCE_NAME}" | tr ' /:' '---' | tr -cd '[:alnum:]-')
  CW_NAMESPACE="CWAgent-${SAFE_INSTANCE_NAME}-Limited"

  export INSTANCE_ID INSTANCE_NAME SAFE_INSTANCE_NAME CW_NAMESPACE
  log "ℹ️  INSTANCE_ID=${INSTANCE_ID}"
  log "ℹ️  INSTANCE_NAME=${INSTANCE_NAME}"
  log "ℹ️  CW_NAMESPACE=${CW_NAMESPACE}"
}

########################################
# SSH Keys
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
    val=""
    for attempt in {1..5}; do
      val="$(aws ssm get-parameter \
        --name "$param" \
        --with-decryption \
        --region "$REGION" \
        --query 'Parameter.Value' \
        --output text 2>/dev/null || true)"
      
      if [[ -n "$val" && "$val" != "None" ]]; then
        break
      fi
      
      if [[ $attempt -lt 5 ]]; then
        log "   ⏳ Retrying $param (attempt $attempt/5)..."
        sleep 2
      fi
    done

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
# Base Utils, Docker, CodeDeploy
########################################
install_base_utils() {
  log "📦 Installing base utils (AWS CLI, git, Docker, etc.)..."
  apt-get update -y
  apt-get install -y \
    awscli git ca-certificates curl gnupg lsb-release netcat unzip jq

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

  log "✅ AWS CLI / git / docker installed"
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
  fi

  rm -f /tmp/install
}

########################################
# DBT Secrets & Runtime
########################################
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

set_redshift_param_paths() {
  SSM_RS_HOST="/backend/${ENV_NAME}/REDSHIFT_HOST"
  SSM_RS_DB="/backend/${ENV_NAME}/REDSHIFT_DATABASE"
  SSM_RS_USER="/backend/${ENV_NAME}/REDSHIFT_USERNAME"
  SSM_RS_PASS="/backend/${ENV_NAME}/REDSHIFT_PASSWORD"
  SSM_RS_PORT="/backend/${ENV_NAME}/REDSHIFT_PORT"
}

fetch_redshift_secrets_to_envfile() {
  log "🔐 Fetching Redshift credentials from SSM..."
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
  log "✅ Created ${DBT_PROJECT_DIR}"
}


########################################
# Host log/artifact directories for dbt
########################################
prepare_dbt_host_logging_dirs() {
  log "🗂 Preparing /var/log/dbt mount points for container logs & artifacts..."

  # Will receive /usr/app/logs/dbt.log from inside the container
  # and /usr/app/target/{run_results.json,manifest.json,...}
  mkdir -p /var/log/dbt
  mkdir -p /var/log/dbt/target

  # Let the ubuntu user (and docker containers that run as uid 1000) write there
  chown -R "${USERNAME}:${USERNAME}" /var/log/dbt
  chmod -R 755 /var/log/dbt

  log "✅ /var/log/dbt ready (will be mounted into the docs container)"
}


install_docs_systemd_service() {
  log "🛠️ Creating systemd service for dbt-docs..."

  # NOTE: docker-compose.yml in ${DBT_PROJECT_DIR} must mount:
  #   - /var/log/dbt:/usr/app/logs
  #   - /var/log/dbt/target:/usr/app/target
  # so that dbt.log and run_results.json are visible on the host and can be shipped to CloudWatch.
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
  log "✅ dbt-docs.service created and enabled"
}

########################################
# Monitoring Stack
########################################
install_monitoring_stack() {
  log "📈 Installing monitoring stack (CloudWatch Agent, SSM Agent)..."

  # CloudWatch Agent
  if ! command -v /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl >/dev/null 2>&1; then
    log "⬇️ Installing CloudWatch Agent"
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

  # Fetch CloudWatch config from SSM and replace placeholders
  log "🔽 Fetching CloudWatch config from SSM..."
  SSM_CW_CONFIG="/ec2/dbt/${ENV_NAME}/cloudwatch_config"
  
  mkdir -p "$(dirname "$CW_CONFIG_DST")"
  
  aws ssm get-parameter \
    --name "$SSM_CW_CONFIG" \
    --region "$REGION" \
    --query 'Parameter.Value' \
    --output text | \
    sed "s/__NAMESPACE__/${CW_NAMESPACE}/g" | \
    sed "s/__INSTANCE_NAME__/${SAFE_INSTANCE_NAME}/g" > "$CW_CONFIG_DST"

  if [[ ! -f "$CW_CONFIG_DST" || ! -s "$CW_CONFIG_DST" ]]; then
    log "❌ ERROR: CloudWatch config file is empty"
    exit 1
  fi

  log "✅ CloudWatch config fetched and configured"

  # Stop any existing CloudWatch Agent
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a stop -m ec2 2>/dev/null || true

  sleep 2

  # Start CloudWatch Agent
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:"$CW_CONFIG_DST" \
    -s

  sleep 3

  CW_STATUS=$(systemctl is-active amazon-cloudwatch-agent || true)
  SSM_STATUS=$(systemctl is-active snap.amazon-ssm-agent.amazon-ssm-agent || true)

  if [[ "$CW_STATUS" == "active" && "$SSM_STATUS" == "active" ]]; then
    log "✅ Monitoring stack healthy"
  else
    log "❌ Monitoring stack issue"
    log "   CloudWatch: ${CW_STATUS}, SSM: ${SSM_STATUS}"
  fi
  
  log "📊 Monitoring: Namespace ${CW_NAMESPACE}, ~8 metrics"
}

########################################
# Custom Uptime Metric
########################################
install_uptime_metric_script() {
  log "⏱️ Installing custom uptime metric script..."
  
  # Create script with namespace variable substitution
  cat > /usr/local/bin/send-uptime-metric.sh <<SCRIPT
#!/bin/bash

# Get IMDSv2 token
TOKEN=\$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \\
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Get instance ID with token
if [[ -n "\$TOKEN" ]]; then
  INSTANCE_ID=\$(curl -s -H "X-aws-ec2-metadata-token: \$TOKEN" \\
    http://169.254.169.254/latest/meta-data/instance-id)
else
  INSTANCE_ID=\$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
fi

# Get uptime
UPTIME_SECONDS=\$(awk '{print int(\$1)}' /proc/uptime)

# Use the same namespace that CloudWatch Agent uses
NAMESPACE="${CW_NAMESPACE}"

# Send to CloudWatch
aws cloudwatch put-metric-data \\
  --namespace "\$NAMESPACE" \\
  --metric-name uptime_seconds \\
  --value "\$UPTIME_SECONDS" \\
  --dimensions InstanceId="\$INSTANCE_ID" \\
  --region ${REGION}

echo "[\$(date)] Sent uptime: \$UPTIME_SECONDS seconds to namespace \$NAMESPACE for \$INSTANCE_ID"
SCRIPT

  chmod +x /usr/local/bin/send-uptime-metric.sh
  
  # Test it once to send initial metric
  /usr/local/bin/send-uptime-metric.sh >> /var/log/uptime-metric.log 2>&1 || log "⚠️  Initial uptime metric send failed"
  
  # Add to cron (every 5 minutes)
  echo "*/5 * * * * /usr/local/bin/send-uptime-metric.sh >> /var/log/uptime-metric.log 2>&1" | crontab -
  
  log "✅ Uptime metric script installed and scheduled"
  log "   Namespace: ${CW_NAMESPACE}"
}

########################################
# Main
########################################
main() {
  log "🚀 Starting DBT EC2 setup bootstrap..."

  fetch_instance_identity
  normalize_env_name
  set_redshift_param_paths

  # Install base utils FIRST (includes AWS CLI)
  install_base_utils
  
  # NOW we can use AWS CLI for SSH keys and other AWS operations
  configure_ssh_keys_from_ssm
  install_codedeploy_agent

  fetch_redshift_secrets_to_envfile
  write_runtime_profiles_yaml
  prepare_deployment_directory

  # 🔹 NEW: make /var/log/dbt and /var/log/dbt/target on the host
  prepare_dbt_host_logging_dirs

  install_docs_systemd_service

  install_monitoring_stack
  install_uptime_metric_script

  log "🎉 EC2 setup complete!"
  log "📊 Environment: ${ENV_NAME}"
  log "📁 Deployment dir: ${DBT_PROJECT_DIR}"
  log "📈 CloudWatch namespace: ${CW_NAMESPACE}"
}

main "$@"