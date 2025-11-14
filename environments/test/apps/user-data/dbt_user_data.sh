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
    awscli git ca-certificates curl gnupg lsb-release netcat unzip jq python3-pip

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
  log "🔐 Fetching Redshift credentials and SNS topic from SSM..."
  RS_HOST=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_HOST" --query 'Parameter.Value' --output text)
  RS_DB=$(aws ssm get-parameter   --with-decryption --region "$REGION" --name "$SSM_RS_DB"   --query 'Parameter.Value' --output text)
  RS_USER=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_USER" --query 'Parameter.Value' --output text)
  RS_PASS=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_PASS" --query 'Parameter.Value' --output text)
  RS_PORT=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_PORT" --query 'Parameter.Value' --output text)
  
  # Fetch SNS topic ARN
  SNS_TOPIC=$(aws ssm get-parameter --region "$REGION" --name "/ec2/dbt/${ENV_NAME}/sns_topic_arn" --query 'Parameter.Value' --output text 2>/dev/null || echo "")

  mkdir -p "$DBT_BASE_DIR"
  cat > "$DBT_ENV_FILE" <<EOF
DBT_RS_HOST=${RS_HOST}
DBT_RS_DB=${RS_DB}
DBT_RS_USER=${RS_USER}
DBT_RS_PASS=${RS_PASS}
DBT_RS_PORT=${RS_PORT}
DBT_RS_SCHEMA=analytics
SNS_TOPIC_ARN=${SNS_TOPIC}
ENV_NAME=${ENV_NAME}
REGION=${REGION}
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

  mkdir -p /var/log/dbt
  mkdir -p /var/log/dbt/target

  chown -R "${USERNAME}:${USERNAME}" /var/log/dbt
  chmod -R 755 /var/log/dbt

  log "✅ /var/log/dbt ready (will be mounted into the docs container)"
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
  log "✅ dbt-docs.service created and enabled"
}

########################################
# DBT Scheduled Runs
########################################
install_dbt_scheduled_runs() {
  log "⏰ Setting up scheduled DBT runs..."
  
  # Create DBT run script
  cat > /usr/local/bin/dbt-scheduled-run.sh <<'SCRIPT'
#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/dbt/scheduled-runs.log"
RESULT_FILE="/var/log/dbt/target/run_results.json"
ENV_FILE="/opt/dbt/.env"
PROJECT_DIR="/opt/dbt/project"

# Load environment variables
if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
fi

log() {
  echo "[$(date +'%F %T')] $*" | tee -a "$LOG_FILE"
}

send_notification() {
  local status=$1
  local summary=$2
  
  # Only send if SNS topic is configured
  if [[ -z "${SNS_TOPIC_ARN:-}" ]]; then
    log "⚠️  SNS_TOPIC_ARN not configured, skipping notification"
    return 0
  fi
  
  # Get instance details
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null || echo "")
  
  if [[ -n "$TOKEN" ]]; then
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "unknown")
    INSTANCE_NAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/tags/instance/Name 2>/dev/null || echo "Unknown")
  else
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "unknown")
    INSTANCE_NAME="Unknown"
  fi
  
  # Send SNS notification
  aws sns publish \
    --topic-arn "${SNS_TOPIC_ARN}" \
    --subject "DBT Run ${status} - ${INSTANCE_NAME}" \
    --message "$(cat <<EOF
DBT Scheduled Run ${status}

Instance: ${INSTANCE_NAME} (${INSTANCE_ID})
Time: $(date +'%F %T %Z')
Environment: ${ENV_NAME:-unknown}

${summary}

View logs: ssh to instance and check /var/log/dbt/scheduled-runs.log
EOF
)" \
    --region "${REGION:-eu-west-2}" 2>&1 | tee -a "$LOG_FILE" || log "⚠️  Failed to send SNS notification"
}

log "=========================================="
log "🚀 Starting scheduled DBT run"
log "=========================================="

cd "$PROJECT_DIR"

# Run DBT models
log "📊 Running DBT models..."
if docker compose run --rm dbt-core run --log-path /tmp 2>&1 | tee -a "$LOG_FILE"; then
  log "✅ DBT run completed successfully"
  RUN_STATUS="SUCCESS"
else
  log "❌ DBT run failed"
  RUN_STATUS="FAILED"
  
  # Send failure notification immediately
  send_notification "FAILED" "DBT models failed to run. Check logs for details."
  exit 1
fi

# Run DBT tests
log "🧪 Running DBT tests..."
if docker compose run --rm dbt-core test --log-path /tmp 2>&1 | tee -a "$LOG_FILE"; then
  log "✅ DBT tests passed"
  TEST_STATUS="SUCCESS"
else
  log "⚠️  Some DBT tests failed"
  TEST_STATUS="FAILED"
fi

# Generate documentation
log "📚 Generating documentation..."
if docker compose run --rm dbt-core docs generate --log-path /tmp 2>&1 | tee -a "$LOG_FILE"; then
  log "✅ Documentation generated"
  DOCS_STATUS="SUCCESS"
else
  log "⚠️  Documentation generation failed"
  DOCS_STATUS="FAILED"
fi

# Parse results
if [[ -f "$RESULT_FILE" ]]; then
  SUMMARY=$(python3 -c "
import sys, json
try:
    with open('$RESULT_FILE') as f:
        data = json.load(f)
        results = data.get('results', [])
        success = sum(1 for r in results if r.get('status') == 'success')
        error = sum(1 for r in results if r.get('status') == 'error')
        skipped = sum(1 for r in results if r.get('status') == 'skipped')
        print(f'Models: {len(results)} total')
        print(f'✅ Success: {success}')
        print(f'❌ Error: {error}')
        print(f'⏭️  Skipped: {skipped}')
except Exception as e:
    print(f'Could not parse results: {e}')
" 2>/dev/null) || SUMMARY="Results parsing failed"
else
  SUMMARY="No run_results.json found"
fi

log ""
log "📊 Run Summary:"
log "$SUMMARY"
log "Run Status: $RUN_STATUS"
log "Test Status: $TEST_STATUS"
log "Docs Status: $DOCS_STATUS"
log "=========================================="

# Send success notification with summary
if [[ "$RUN_STATUS" == "SUCCESS" ]]; then
  FULL_SUMMARY="DBT Run: $RUN_STATUS
Tests: $TEST_STATUS
Docs: $DOCS_STATUS

$SUMMARY"
  send_notification "SUCCESS" "$FULL_SUMMARY"
fi

log "✅ Scheduled run complete"
SCRIPT

  chmod +x /usr/local/bin/dbt-scheduled-run.sh
  chown "$USERNAME:$USERNAME" /usr/local/bin/dbt-scheduled-run.sh
  
  # Create log rotation for scheduled runs
  cat > /etc/logrotate.d/dbt-scheduled-runs <<'LOGROTATE'
/var/log/dbt/scheduled-runs.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 ubuntu ubuntu
    sharedscripts
}
LOGROTATE

  log "✅ DBT scheduled run script installed"
}

setup_dbt_cron() {
  log "📅 Setting up cron for DBT scheduled runs..."
  
  # Add cron job as ubuntu user
  # Run every 2 hours at 10 minutes past the hour
  CRON_LINE="10 */2 * * * /usr/local/bin/dbt-scheduled-run.sh >> /var/log/dbt/cron.log 2>&1"
  
  # Add to ubuntu user's crontab
  (crontab -u "$USERNAME" -l 2>/dev/null || true; echo "$CRON_LINE") | crontab -u "$USERNAME" -
  
  log "✅ Cron job installed for user: $USERNAME"
  log "   Schedule: Every 2 hours at :10 past the hour"
  log "   Command: /usr/local/bin/dbt-scheduled-run.sh"
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
  prepare_dbt_host_logging_dirs

  install_docs_systemd_service
  
  # 🔹 NEW: Install scheduled DBT runs
  install_dbt_scheduled_runs
  setup_dbt_cron

  install_monitoring_stack
  install_uptime_metric_script

  log "🎉 EC2 setup complete!"
  log "📊 Environment: ${ENV_NAME}"
  log "📁 Deployment dir: ${DBT_PROJECT_DIR}"
  log "📈 CloudWatch namespace: ${CW_NAMESPACE}"
  log "⏰ Scheduled runs: Every 2 hours at :10 past the hour"
}

main "$@"