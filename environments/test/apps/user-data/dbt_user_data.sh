#!/bin/bash
set -euo pipefail

# ========= Configuration (Terraform injects ENV_NAME and REGION before this script runs) =========
REGION="${REGION:-eu-west-2}"
ENV_NAME="${ENV_NAME:-staging}"
# ================================================================================================

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

# ========= Environment selection (test/staging/production) =========
ENV_NAME_INPUT="${ENV_NAME:-staging}"

case "${ENV_NAME_INPUT,,}" in
  prod|production) ENV_NAME="production" ;;
  stage|staging|stg) ENV_NAME="staging" ;;
  test|testing|tst) ENV_NAME="test" ;;
  *)
    echo "[ERROR] ENV_NAME '${ENV_NAME_INPUT}' is invalid. Use: test | staging | production"
    exit 1
    ;;
esac
echo "[INFO] Using ENV_NAME='${ENV_NAME}'"

# Redshift secrets in SSM (environment-specific)
SSM_RS_HOST="/backend/${ENV_NAME}/REDSHIFT_HOST"
SSM_RS_DB="/backend/${ENV_NAME}/REDSHIFT_DATABASE"
SSM_RS_USER="/backend/${ENV_NAME}/REDSHIFT_USERNAME"
SSM_RS_PASS="/backend/${ENV_NAME}/REDSHIFT_PASSWORD"
SSM_RS_PORT="/backend/${ENV_NAME}/REDSHIFT_PORT"

DBT_BASE_DIR="/opt/dbt"
DBT_PROJECT_DIR="${DBT_BASE_DIR}/project"
DBT_RUNTIME_DIR="${DBT_BASE_DIR}/runtime"
DBT_ENV_FILE="${DBT_BASE_DIR}/.env"
DBT_PROFILES_FILE="${DBT_RUNTIME_DIR}/profiles.yml"

DBT_PROFILE_NAME="${DBT_PROFILE_NAME:-carl}"
DBT_TARGET_NAME="${DBT_TARGET_NAME:-dev}"

log() { echo "[$(date +'%F %T')] $*"; }

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
    val="$(aws ssm get-parameter --name "$param" --with-decryption --region "$REGION" --query 'Parameter.Value' --output text 2>/dev/null || true)"
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

install_base_utils() {
  log "📦 Installing AWS CLI, Git, and Docker..."
  apt-get update -y
  apt-get install -y awscli git ca-certificates curl gnupg lsb-release netcat

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  systemctl enable --now docker
  usermod -aG docker "$USERNAME" || true

  log "✅ Installed AWS CLI, Git, Docker, and Docker Compose"
}

install_codedeploy_agent() {
  log "🚀 Installing AWS CodeDeploy Agent..."
  
  apt-get install -y ruby-full wget
  
  cd /tmp
  wget "https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install"
  chmod +x ./install
  
  ./install auto
  
  if systemctl is-active --quiet codedeploy-agent; then
    log "✅ CodeDeploy agent installed and running"
  else
    log "⚠️  CodeDeploy agent installed but not running, attempting to start..."
    systemctl start codedeploy-agent
    systemctl enable codedeploy-agent
    sleep 2
    if systemctl is-active --quiet codedeploy-agent; then
      log "✅ CodeDeploy agent started successfully"
    else
      log "❌ Failed to start CodeDeploy agent"
      systemctl status codedeploy-agent --no-pager
    fi
  fi
  
  rm -f /tmp/install
  
  log "✅ CodeDeploy agent setup complete"
}

fetch_redshift_secrets_to_envfile() {
  log "🔐 Fetching Redshift credentials from SSM (${ENV_NAME})..."
  RS_HOST=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_HOST" --query 'Parameter.Value' --output text)
  RS_DB=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$SSM_RS_DB" --query 'Parameter.Value' --output text)
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
  log "✅ Created .env file at ${DBT_ENV_FILE}"
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
  log "✅ Created profiles.yml at ${DBT_PROFILES_FILE}"
}

prepare_deployment_directory() {
  log "📁 Preparing deployment directory..."
  mkdir -p "$DBT_PROJECT_DIR"
  chown -R "$USERNAME:$USERNAME" "$DBT_BASE_DIR"
  log "✅ Created ${DBT_PROJECT_DIR} (CodeDeploy will populate this)"
}

install_docs_systemd_service() {
  log "🛠️  Creating systemd service for docs server..."
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
  log "   (Service will start after CodeDeploy deployment)"
}

main() {
  log "🚀 Starting DBT EC2 setup for ${ENV_NAME} environment..."
  log "   This instance will be deployed via AWS CodeDeploy"

  configure_ssh_keys_from_ssm
  install_base_utils
  install_codedeploy_agent
  fetch_redshift_secrets_to_envfile
  write_runtime_profiles_yaml
  prepare_deployment_directory
  install_docs_systemd_service

  log "🎉 EC2 setup complete! Ready for CodeDeploy deployments"
  log "📊 Environment: ${ENV_NAME}"
  log "📁 Deployment directory: ${DBT_PROJECT_DIR}"
  log "🚀 CodeDeploy agent: Active"
  log ""
  log "Next steps:"
  log "  1. CodeDeploy will deploy the DBT project to ${DBT_PROJECT_DIR}"
  log "  2. The deployment will start the dbt-docs.service"
  log "  3. Docs will be available on port 8080"
  log ""
  log "To check status after deployment:"
  log "  - systemctl status codedeploy-agent"
  log "  - systemctl status dbt-docs.service"
  log "  - docker compose ps (from ${DBT_PROJECT_DIR})"
  log "  - docker compose logs docs"
}

main "$@"