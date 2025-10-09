#!/bin/bash
set -euxo pipefail

# ========= Config =========
REGION="${REGION:-eu-west-2}"
REDIS_PREFIX="$(aws ssm get-parameter --name "/kuflink/test/redis-param-prefix" --region "$REGION" --query 'Parameter.Value' --output text)"
SSM_REDIS_PASS_PARAM="${SSM_REDIS_PASS_PARAM:-${REDIS_PREFIX}/REDIS_PASSWORD}"
USERNAME="${USERNAME:-ec2-user}"
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
# ==========================

log() { echo "[$(date +'%F %T')] $*"; }

detect_os() {
  # Sets: OS_FAMILY in {AL2, AL2023, OTHER}
  if grep -qi "Amazon Linux 2" /etc/system-release 2>/dev/null; then
    OS_FAMILY="AL2"
  elif grep -qi "Amazon Linux release 2023" /etc/system-release 2>/dev/null; then
    OS_FAMILY="AL2023"
  else
    OS_FAMILY="OTHER"
  fi
  export OS_FAMILY
  log "🖥️  Detected OS family: ${OS_FAMILY}"
}

install_base_utils() {
  log "📦 Installing base utils (awscli/jq/socat/mysql/postgresql)"
  if command -v dnf >/dev/null 2>&1; then
    dnf install -y -q awscli jq postgresql socat || true
    dnf install -y -q mysql || dnf install -y -q mariadb || true
  else
    yum install -y -q aws-cli jq postgresql socat || true
    yum install -y -q mysql || yum install -y -q mariadb || true
  fi
}

install_redis() {
  if command -v redis-server >/dev/null 2>&1; then
    log "✅ redis-server already present"
    return 0
  fi

  log "📦 Installing Redis..."
  if [[ "$OS_FAMILY" == "AL2" ]]; then
    # Prefer amazon-linux-extras on AL2
    if command -v amazon-linux-extras >/dev/null 2>&1; then
      # Try redis6 topic; fall back to yum repo if present
      amazon-linux-extras install -y redis6 || true
    fi
    yum install -y -q redis || true
  elif [[ "$OS_FAMILY" == "AL2023" ]]; then
    dnf install -y -q redis || true
  else
    # Generic fallback
    if command -v dnf >/dev/null 2>&1; then
      dnf install -y -q redis || true
    else
      yum install -y -q redis || true
    fi
  fi

  if ! command -v redis-server >/dev/null 2>&1; then
    log "❌ Could not install redis-server. This is almost always a networking issue."
    cat <<'TIPS'
Fix one of the following and re-run this script:
  1) Private subnet + NAT: Ensure the route table has 0.0.0.0/0 -> NAT, SG egress open, NACLs allow ephemeral ports.
  2) No NAT: Create VPC Endpoints:
     - Gateway:  com.amazonaws.${REGION}.s3  (attach to the route table of this subnet)
     - Interface: com.amazonaws.${REGION}.{ssm,ssmmessages,ec2messages,kms} (attach SG with egress)
Then run:  sudo bash /var/lib/cloud/instance/scripts/part-001
TIPS
    exit 2
  fi
}

configure_paths() {
  # Paths for redis on AL/RHEL family
  REDIS_CONF="/etc/redis/redis.conf"
  REDIS_SVC="redis"

  # Some builds might drop /etc/redis.conf instead. Normalize to /etc/redis/redis.conf.
  if [[ ! -f "$REDIS_CONF" && -f "/etc/redis.conf" ]]; then
    mkdir -p /etc/redis
    mv /etc/redis.conf "$REDIS_CONF"
  fi

  export REDIS_CONF REDIS_SVC
}

configure_ssh_keys_from_ssm() {
  log "🔑 Building $AUTHORIZED_KEYS from SSM parameters..."
  mkdir -p "$SSH_DIR"; chown "$USERNAME:$USERNAME" "$SSH_DIR"; chmod 700 "$SSH_DIR"
  : > "${AUTHORIZED_KEYS}.tmp"

  if [[ -f "$AUTHORIZED_KEYS" && "$PRESERVE_EXISTING_AUTH_KEYS" == "true" ]]; then
    log "🧷 Preserving existing keys from $AUTHORIZED_KEYS"
    tr '\r' '\n' < "$AUTHORIZED_KEYS" | sed '/^[[:space:]]*$/d' >> "${AUTHORIZED_KEYS}.tmp"
  fi

  for param in "${PUBLIC_KEY_PARAMS[@]}"; do
    val="$(aws ssm get-parameter --name "$param" --with-decryption --region "$REGION" \
           --query 'Parameter.Value' --output text 2>/dev/null || true)"
    if [[ -n "$val" && "$val" != "None" ]] && echo "$val" | grep -Eq '^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp256) '; then
      echo "$val" >> "${AUTHORIZED_KEYS}.tmp"; log "   ➕ Added key from $param"
    else
      log "   ⚠️  $param: missing/invalid"
    fi
  done

  if [[ -s "${AUTHORIZED_KEYS}.tmp" ]]; then
    sort -u "${AUTHORIZED_KEYS}.tmp" > "$AUTHORIZED_KEYS"
    rm -f "${AUTHORIZED_KEYS}.tmp"
    chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS"; chmod 600 "$AUTHORIZED_KEYS"
    log "✅ Installed $(wc -l < "$AUTHORIZED_KEYS") SSH keys"
  else
    rm -f "${AUTHORIZED_KEYS}.tmp" || true
    log "⚠️  No valid keys written to $AUTHORIZED_KEYS"
  fi
}

fetch_redis_password() {
  aws ssm get-parameter \
    --region "$REGION" \
    --name "$SSM_REDIS_PASS_PARAM" \
    --with-decryption \
    --query 'Parameter.Value' --output text
}

write_redis_conf() {
  local pass="$1"
  local conf="${REDIS_CONF:-/etc/redis/redis.conf}"

  log "📝 Writing ${conf} (AOF=no, RDB=yes, noeviction)..."
  install -d -o redis -g redis /var/lib/redis || true
  install -d -o redis -g redis /etc/redis || true

  # Backup any existing
  if [[ -f "$conf" ]]; then
    cp -a "$conf" "${conf}.default.$(date +%s)"
  fi

  cat > "$conf" <<'EOF'
bind 0.0.0.0 ::1
protected-mode yes
port 6379
timeout 0
tcp-keepalive 300

# Security
# requirepass <injected-below>

# Systemd supervision
supervised systemd
daemonize no

# Persistence (RDB enabled; AOF disabled)
save 3600 1
save 300 100
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /var/lib/redis

appendonly no
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# Memory policy
maxmemory 0
maxmemory-policy noeviction

# Logging
loglevel notice
# logfile ""    # use journald
EOF

  # Inject requirepass
  if grep -q '^[[:space:]]*requirepass' "$conf"; then
    sed -i "s|^[[:space:]]*requirepass .*|requirepass ${pass}|" "$conf"
  else
    echo "requirepass ${pass}" >> "$conf"
  fi

  chown redis:redis "$conf"
  chmod 640 "$conf" || true
}

kernel_tweaks_for_redis() {
  log "🧠 Applying kernel tweaks (vm.overcommit_memory=1, THP off)..."
  sysctl -w vm.overcommit_memory=1
  echo "vm.overcommit_memory = 1" > /etc/sysctl.d/99-redis.conf

  if [ -d /sys/kernel/mm/transparent_hugepage ]; then
    echo never > /sys/kernel/mm/transparent_hugepage/enabled || true
    echo never > /sys/kernel/mm/transparent_hugepage/defrag || true
    if [ ! -f /etc/rc.local ]; then
      printf '#!/bin/sh\nexit 0\n' > /etc/rc.local
      chmod +x /etc/rc.local
    fi
    sed -i '/transparent_hugepage/d' /etc/rc.local
    sed -i '1i echo never > /sys/kernel/mm/transparent_hugepage/enabled || true' /etc/rc.local
    sed -i '2i echo never > /sys/kernel/mm/transparent_hugepage/defrag || true' /etc/rc.local
  fi
}

start_and_check_redis() {
  log "🚀 Enabling & starting Redis..."
  systemctl daemon-reload || true
  systemctl enable "${REDIS_SVC}"
  systemctl stop "${REDIS_SVC}" || true
  systemctl start "${REDIS_SVC}"

  log "🔎 Health check (PING)..."
  local p
  p="$(fetch_redis_password)"
  if [[ -z "$p" || "$p" == "None" ]]; then
    log "❌ Empty password from SSM; cannot health-check."
    exit 1
  fi
  redis-cli -h 127.0.0.1 -p 6379 -a "$p" PING | grep -qi "PONG" || { journalctl -u "${REDIS_SVC}" --no-pager | tail -n 200; exit 1; }
  log "✅ Redis is up and responding to AUTHed PING."
}

# ---------- Main ----------
main() {
  detect_os
  install_base_utils
  install_redis
  configure_paths

  configure_ssh_keys_from_ssm

  local redis_pass
  redis_pass="$(fetch_redis_password)"   # requires: ssm:GetParameter + kms:Decrypt
  if [[ -z "$redis_pass" || "$redis_pass" == "None" ]]; then
    log "❌ SSM password fetch returned empty; aborting."
    exit 1
  fi

  write_redis_conf "$redis_pass"
  kernel_tweaks_for_redis
  start_and_check_redis
  log "🎉 EC2 provisioning completed at: $(date)"
}

main "$@"
