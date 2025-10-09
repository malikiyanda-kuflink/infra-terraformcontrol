#!/bin/bash
set -euxo pipefail

# ========= Config =========
REGION="${REGION:-eu-west-2}"
USERNAME="${USERNAME:-ubuntu}"
SSH_DIR="/home/${USERNAME}/.ssh"
AUTHORIZED_KEYS="${AUTHORIZED_KEYS:-${SSH_DIR}/authorized_keys}"
PRESERVE_EXISTING_AUTH_KEYS="${PRESERVE_EXISTING_AUTH_KEYS:-true}"

SSH_PREFIX="$(aws ssm get-parameter --name "/kuflink/test/ssh-key-param-prefix" --region "$REGION" --query 'Parameter.Value' --output text)"
PUBLIC_KEY_PARAMS=(
  "${SSH_PREFIX}/ArchitectPublicKey"
  "${SSH_PREFIX}/DevOpsPublicKey" 
  "${SSH_PREFIX}/TeamLeadPublicKey"
  "${SSH_PREFIX}/TechLeadPublicKey"
)

# Redshift secrets in SSM 
REDSHIFT_PREFIX="$(aws ssm get-parameter --name "/kuflink/test/redshift-param-prefix" --region "$REGION" --query 'Parameter.Value' --output text)"
SSM_RS_HOST="${REDSHIFT_PREFIX}/REDSHIFT_HOST"
SSM_RS_DB="${REDSHIFT_PREFIX}/REDSHIFT_DATABASE"
SSM_RS_USER="${REDSHIFT_PREFIX}/REDSHIFT_USERNAME"
SSM_RS_PASS="${REDSHIFT_PREFIX}/REDSHIFT_PASSWORD"
SSM_RS_PORT="${REDSHIFT_PREFIX}/REDSHIFT_PORT"

# GitHub PAT (read-only) in SSM
GITHUB_PAT_PARAM="$(aws ssm get-parameter --name "/kuflink/test/github-pat-param" --region "$REGION" --query 'Parameter.Value' --output text)"

DBT_BASE_DIR="/opt/dbt"
DBT_PROJECT_DIR="${DBT_BASE_DIR}/project"
DBT_RUNTIME_DIR="${DBT_BASE_DIR}/runtime"
DBT_ENV_FILE="${DBT_BASE_DIR}/.env"
DBT_PROFILES_FILE="${DBT_RUNTIME_DIR}/profiles.yml"

DBT_REPO_URL="$(aws ssm get-parameter --name "/kuflink/test/dbt-repo-url" --region "$REGION" --query 'Parameter.Value' --output text)"
DBT_REPO_BRANCH="$(aws ssm get-parameter --name "/kuflink/test/dbt-repo-branch" --region "$REGION" --query 'Parameter.Value' --output text)"

# dbt runtime profile (must match repo dbt_project.yml -> profile:)
DBT_PROFILE_NAME="${DBT_PROFILE_NAME:-dbt-ec2}"
DBT_TARGET_NAME="${DBT_TARGET_NAME:-dev}"
# ==========================

log(){ echo "[$(date +'%F %T')] $*"; }

configure_ssh_keys_from_ssm() {
  log "🔑 Installing SSH keys from SSM..."
  mkdir -p "$SSH_DIR"; chown "$USERNAME:$USERNAME" "$SSH_DIR"; chmod 700 "$SSH_DIR"
  : > "${AUTHORIZED_KEYS}.tmp"
  if [[ -f "$AUTHORIZED_KEYS" && "$PRESERVE_EXISTING_AUTH_KEYS" == "true" ]]; then
    tr '\r' '\n' < "$AUTHORIZED_KEYS" | sed '/^[[:space:]]*$/d' >> "${AUTHORIZED_KEYS}.tmp"
  fi
  for param in "${PUBLIC_KEY_PARAMS[@]}"; do
    val="$(aws ssm get-parameter --name "$param" --with-decryption --region "$REGION" --query 'Parameter.Value' --output text 2>/dev/null || true)"
    if [[ -n "$val" && "$val" != "None" ]] && echo "$val" | grep -Eq '^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp256) '; then
      echo "$val" >> "${AUTHORIZED_KEYS}.tmp"; log "   ➕ $param"
    else
      log "   ⚠️  $param: missing/invalid"
    fi
  done
  if [[ -s "${AUTHORIZED_KEYS}.tmp" ]]; then
    sort -u "${AUTHORIZED_KEYS}.tmp" > "$AUTHORIZED_KEYS"
    rm -f "${AUTHORIZED_KEYS}.tmp"
    chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS"; chmod 600 "$AUTHORIZED_KEYS"
    log "✅ Installed $(wc -l < "$AUTHORIZED_KEYS") keys"
  else
    rm -f "${AUTHORIZED_KEYS}.tmp" || true
    log "⚠️  No keys written"
  fi
}

install_base_utils() {
  log "📦 Installing awscli/git/Docker..."
  apt-get update -y
  apt-get install -y awscli git ca-certificates curl gnupg lsb-release netcat
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable --now docker
  usermod -aG docker "$USERNAME" || true
}

fetch_redshift_secrets_to_envfile() {
  log "🔐 Fetching Redshift creds from SSM -> ${DBT_ENV_FILE}"
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
  chown "$USERNAME":"$USERNAME" "$DBT_ENV_FILE"; chmod 600 "$DBT_ENV_FILE"
  log "✅ Wrote ${DBT_ENV_FILE}"
}

write_runtime_profiles_yaml() {
  log "📝 Writing runtime profiles.yml -> ${DBT_PROFILES_FILE}"
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
  chown "$USERNAME":"$USERNAME" "$DBT_PROFILES_FILE"; chmod 640 "$DBT_PROFILES_FILE"
  log "✅ Wrote ${DBT_PROFILES_FILE}"
}

fetch_github_pat() {
  log "🔑 Fetching GitHub token from SSM..."
  GITHUB_PAT="$(aws ssm get-parameter --with-decryption --region "$REGION" --name "$GITHUB_PAT_PARAM" --query 'Parameter.Value' --output text || true)"
  if [[ -z "$GITHUB_PAT" || "$GITHUB_PAT" == "None" ]]; then
    log "❌ Missing GitHub PAT in SSM: $GITHUB_PAT_PARAM"; exit 1
  fi
  GITHUB_PAT="${GITHUB_PAT//$'\r'/}"; GITHUB_PAT="${GITHUB_PAT//$'\n'/}"
}

clone_dbt_repo() {
  log "📂 Cloning dbt repo (token auth)…"
  mkdir -p "$DBT_PROJECT_DIR"; chown -R "$USERNAME:$USERNAME" "$DBT_BASE_DIR"
  export GIT_TERMINAL_PROMPT=0
  AUTH="$(printf 'x-access-token:%s' "$GITHUB_PAT" | base64 | tr -d '\r\n')"
  local GIT_AUTH_CFG=(
    -c "http.https://github.com/.extraheader=Authorization: Basic ${AUTH}"
    -c "http.https://codeload.github.com/.extraheader=Authorization: Basic ${AUTH}"
  )
  if [ ! -d "${DBT_PROJECT_DIR}/.git" ]; then
    set +x; sudo -u "$USERNAME" git "${GIT_AUTH_CFG[@]}" ls-remote "$DBT_REPO_URL" >/dev/null; set -x
    sudo -u "$USERNAME" git "${GIT_AUTH_CFG[@]}" clone --branch "$DBT_REPO_BRANCH" "$DBT_REPO_URL" "$DBT_PROJECT_DIR"
    log "✅ Cloned $DBT_REPO_URL ($DBT_REPO_BRANCH)"
  else
    log "ℹ️ Repo exists, updating…"
    set +x; sudo -u "$USERNAME" git -C "$DBT_PROJECT_DIR" "${GIT_AUTH_CFG[@]}" fetch --all --prune; set -x
    sudo -u "$USERNAME" git -C "$DBT_PROJECT_DIR" checkout "$DBT_REPO_BRANCH"
    set +x; sudo -u "$USERNAME" git -C "$DBT_PROJECT_DIR" "${GIT_AUTH_CFG[@]}" pull --ff-only; set -x
    log "✅ Updated repo to $DBT_REPO_BRANCH"
  fi
}

ensure_paths_and_env_link() {
  mkdir -p "${DBT_RUNTIME_DIR}"
  chown "$USERNAME:$USERNAME" "${DBT_RUNTIME_DIR}"
  ln -sf "${DBT_ENV_FILE}" "${DBT_PROJECT_DIR}/.env"
}

start_dbt_oneoff_optional() {
  log "🏁 Optional dbt smoke test…"
  cd "$DBT_PROJECT_DIR"
  docker compose pull || true
  # With entrypoint=["dbt"], this runs 'dbt debug'
  docker compose run --rm dbt debug || true
}

install_docs_systemd_repo_owned() {
  log "🛠️ Creating systemd unit (repo-owned compose)…"
  cat > /etc/systemd/system/dbt-docs.service <<UNIT
[Unit]
Description=dbt docs server (Docker via repo compose)
Wants=docker.service
After=docker.service

[Service]
Type=simple
WorkingDirectory=${DBT_PROJECT_DIR}
ExecStart=/usr/bin/docker compose up -d docs
ExecStop=/usr/bin/docker compose down
Restart=on-failure
RemainAfterExit=true
Environment=DBT_PROFILES_DIR=/root/.dbt
Environment=DBT_PROFILE=${DBT_PROFILE_NAME}
Environment=DBT_TARGET=${DBT_TARGET_NAME}

[Install]
WantedBy=multi-user.target
UNIT
  systemctl daemon-reload
  systemctl enable --now dbt-docs.service
  log "✅ dbt-docs.service enabled & started"
}

main() {
  configure_ssh_keys_from_ssm
  install_base_utils
  fetch_redshift_secrets_to_envfile
  write_runtime_profiles_yaml
  fetch_github_pat
  clone_dbt_repo
  ensure_paths_and_env_link
  start_dbt_oneoff_optional
  install_docs_systemd_repo_owned
  log "🎉 DBT on EC2 is up. Docs on port 8080 (repo-owned compose)."
}

main "$@"
