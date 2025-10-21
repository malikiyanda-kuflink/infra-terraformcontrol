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
# Accept common aliases, normalize to: test | staging | production
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
# ================================================================

# Redshift secrets in SSM (environment-specific)
SSM_RS_HOST="/backend/${ENV_NAME}/REDSHIFT_HOST"
SSM_RS_DB="/backend/${ENV_NAME}/REDSHIFT_DATABASE"
SSM_RS_USER="/backend/${ENV_NAME}/REDSHIFT_USERNAME"
SSM_RS_PASS="/backend/${ENV_NAME}/REDSHIFT_PASSWORD"
SSM_RS_PORT="/backend/${ENV_NAME}/REDSHIFT_PORT"

# GitHub configuration in SSM (environment-specific)
GITHUB_PAT_PARAM="/github/pat/dbt_redshift_ro"
GITHUB_REPO_URL_PARAM="/dbt/${ENV_NAME}/REPO_URL"
GITHUB_REPO_BRANCH_PARAM="/dbt/${ENV_NAME}/REPO_BRANCH"

DBT_BASE_DIR="/opt/dbt"
DBT_PROJECT_DIR="${DBT_BASE_DIR}/project"
DBT_RUNTIME_DIR="${DBT_BASE_DIR}/runtime"
DBT_ENV_FILE="${DBT_BASE_DIR}/.env"
DBT_PROFILES_FILE="${DBT_RUNTIME_DIR}/profiles.yml"

# DBT runtime profile (must match repo dbt_project.yml -> profile:)
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

  # Add Docker official GPG key (suppress overwrite prompt)
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
  chmod a+r /etc/apt/keyrings/docker.gpg

  # Add Docker repository
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list

  # Install Docker
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # Enable Docker service
  systemctl enable --now docker

  # Add ubuntu user to docker group
  usermod -aG docker "$USERNAME" || true

  log "✅ Installed AWS CLI, Git, Docker, and Docker Compose"
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

fetch_github_config() {
  log "🔑 Fetching GitHub configuration from SSM (${ENV_NAME})..."

  GITHUB_PAT="$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$GITHUB_PAT_PARAM" --query 'Parameter.Value' --output text || true)"
  if [[ -z "$GITHUB_PAT" || "$GITHUB_PAT" == "None" ]]; then
    log "❌ Missing GitHub PAT in SSM: $GITHUB_PAT_PARAM"
    exit 1
  fi

  GITHUB_PAT="${GITHUB_PAT//$'\r'/}"
  GITHUB_PAT="${GITHUB_PAT//$'\n'/}"

  DBT_REPO_URL="$(aws ssm get-parameter --region "$REGION" --name "$GITHUB_REPO_URL_PARAM" --query 'Parameter.Value' --output text || true)"
  if [[ -z "$DBT_REPO_URL" || "$DBT_REPO_URL" == "None" ]]; then
    log "❌ Missing repository URL in SSM: $GITHUB_REPO_URL_PARAM"
    exit 1
  fi

  DBT_REPO_BRANCH="$(aws ssm get-parameter --region "$REGION" --name "$GITHUB_REPO_BRANCH_PARAM" --query 'Parameter.Value' --output text || true)"
  if [[ -z "$DBT_REPO_BRANCH" || "$DBT_REPO_BRANCH" == "None" ]]; then
    log "❌ Missing repository branch in SSM: $GITHUB_REPO_BRANCH_PARAM"
    exit 1
  fi

  log "✅ Retrieved GitHub config - Repo: ${DBT_REPO_URL}, Branch: ${DBT_REPO_BRANCH}"
}

clone_dbt_repo() {
  log "📂 Cloning DBT repository from GitHub..."
  mkdir -p "$DBT_PROJECT_DIR"
  chown -R "$USERNAME:$USERNAME" "$DBT_BASE_DIR"

  REPO_PATH="${DBT_REPO_URL#https://github.com/}"
  local REPO_URL_WITH_AUTH="https://x-access-token:${GITHUB_PAT}@github.com/${REPO_PATH}"

  if [ ! -d "${DBT_PROJECT_DIR}/.git" ]; then
    sudo -u "$USERNAME" git clone --branch "$DBT_REPO_BRANCH" "$REPO_URL_WITH_AUTH" "$DBT_PROJECT_DIR"
    log "✅ Cloned ${DBT_REPO_URL} (branch: ${DBT_REPO_BRANCH})"
  else
    log "ℹ️  Repository already exists, updating..."
    cd "$DBT_PROJECT_DIR"
    
    # Clean up any local changes (including old profiles.yml)
    sudo -u "$USERNAME" git reset --hard
    
    sudo -u "$USERNAME" git remote set-url origin "$REPO_URL_WITH_AUTH"
    sudo -u "$USERNAME" git fetch --all --prune
    sudo -u "$USERNAME" git checkout "$DBT_REPO_BRANCH"
    sudo -u "$USERNAME" git pull --ff-only
    log "✅ Updated repository to ${DBT_REPO_BRANCH}"
  fi
}

ensure_paths_and_env_link() {
  log "🔗 Creating symlinks and setting permissions..."
  mkdir -p "$DBT_RUNTIME_DIR"
  chown "$USERNAME:$USERNAME" "$DBT_RUNTIME_DIR"

  ln -sf "$DBT_ENV_FILE" "${DBT_PROJECT_DIR}/.env"
  log "✅ Environment linked to project directory"
}

start_dbt_smoke_test() {
  log "🧪 Running DBT connection test..."
  cd "$DBT_PROJECT_DIR"

  # Detect DBT service by trying each possibility
  log "Testing DBT connection..."
  local dbt_service=""
  
  for service in "dbt-core" "dbt_core" "dbt"; do
    if docker compose config 2>&1 | grep -q "^\s*${service}:"; then
      dbt_service="$service"
      log "Found DBT service: ${dbt_service}"
      break
    fi
  done
  
  if [[ -n "$dbt_service" ]]; then
    # Rebuild to pick up new volume mounts
    docker compose build "$dbt_service" >/dev/null 2>&1 || true
    # Run debug
    docker compose run --rm "$dbt_service" debug || log "⚠️  DBT debug failed (non-critical)"
  else
    log "⚠️  Could not detect DBT service, skipping connection test"
  fi
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
  
  # Start the service and wait a moment for it to initialize
  systemctl start dbt-docs.service
  sleep 5
  
  # Check if docs container is running
  cd "$DBT_PROJECT_DIR"
  if docker compose ps docs 2>/dev/null | grep -q "Up"; then
    log "✅ dbt-docs.service created, enabled, and started successfully"
  else
    log "⚠️  dbt-docs.service created but docs container may not be running"
    log "Check logs with: docker compose logs docs"
  fi
}

main() {
  log "🚀 Starting DBT EC2 setup for ${ENV_NAME} environment..."

  configure_ssh_keys_from_ssm
  install_base_utils
  fetch_redshift_secrets_to_envfile
  write_runtime_profiles_yaml
  fetch_github_config
  clone_dbt_repo
  ensure_paths_and_env_link
  start_dbt_smoke_test
  install_docs_systemd_service

  log "🎉 DBT EC2 setup complete! Documentation server running on port 8080"
  log "📊 Environment: ${ENV_NAME}"
  log "📊 Repository: ${DBT_REPO_URL}"
  log "📊 Branch: ${DBT_REPO_BRANCH}"
  log "🌐 Access docs via ALB once DNS is configured"
  log ""
  log "To check status:"
  log "  - systemctl status dbt-docs.service"
  log "  - docker compose ps"
  log "  - docker compose logs docs"
}

main "$@"