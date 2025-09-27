#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ---------- IMDSv2 helpers ----------
get_token() {
  curl -sS -X PUT "http://169.254.169.254/latest/api/token" \
       -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"
}
imds() {
  local path="$1"
  curl -sS -f -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" \
       "http://169.254.169.254${path}" || true
}

IMDS_TOKEN="$(get_token)"
AZ="$(imds /latest/meta-data/placement/availability-zone)"
REGION="${AZ::-1}"

BASTION_PRIVATE_IP="$(imds /latest/meta-data/local-ipv4)"
BASTION_PUBLIC_IP="$(imds /latest/meta-data/public-ipv4)"

# ---------- Config from instance TAGS (optional) ----------
# Requires: metadata_options.instance_metadata_tags = "enabled"
TARGET_HOST="$(imds /latest/meta-data/tags/instance/DB_HOST)"
FORWARD_PORT="$(imds /latest/meta-data/tags/instance/FORWARD_PORT)"
TARGET_PORT="$(imds /latest/meta-data/tags/instance/TARGET_PORT)"

SSH_PREFIX="$(aws ssm get-parameter --name "/kuflink/test/ssh-key-param-prefix" --region "$REGION" --query 'Parameter.Value' --output text)"
TARGET_HOST_PARAM="$(aws ssm get-parameter --name "/kuflink/test/bastion-target-host" --region "$REGION" --query 'Parameter.Value' --output text)"

# ---------- Defaults & validation ----------
: "${TARGET_HOST:=${TARGET_HOST_PARAM}}"   # <-- RDS endpoint, NOT the proxy DNS
: "${FORWARD_PORT:=9990}"
: "${TARGET_PORT:=3306}"

[[ "$FORWARD_PORT" =~ ^[0-9]+$ ]] || FORWARD_PORT=9990
[[ "$TARGET_PORT"  =~ ^[0-9]+$ ]] || TARGET_PORT=3306

USERNAME="ec2-user"
SSH_DIR="/home/$USERNAME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

echo "🟢 Bootstrapping bastion"
echo "   • Region: $REGION"
echo "   • Forward: 0.0.0.0:$FORWARD_PORT → $TARGET_HOST:$TARGET_PORT"
echo "   • Public IP: ${BASTION_PUBLIC_IP:-<none>}"
echo "   • Private IP: ${BASTION_PRIVATE_IP:-<none>}"

# ---------- Packages ----------
echo "📦 Installing prerequisites..."
yum install -y -q aws-cli jq postgresql socat || true
# MySQL client may already be MariaDB on AL2; don't fail if already present
yum install -y -q mysql || yum install -y -q mariadb || true

# ---------- SSH keys from SSM ----------
PRESERVE_EXISTING_AUTH_KEYS="${PRESERVE_EXISTING_AUTH_KEYS:-true}"
echo "🔑 Building $AUTHORIZED_KEYS from SSM parameters:"
PUBLIC_KEY_PARAMS=(
  "${SSH_PREFIX}/ArchitectPublicKey"
  "${SSH_PREFIX}/DevOpsPublicKey"
  "${SSH_PREFIX}/TeamLeadPublicKey"
  "${SSH_PREFIX}/TechLeadPublicKey"
)

mkdir -p "$SSH_DIR"; chown "$USERNAME:$USERNAME" "$SSH_DIR"; chmod 700 "$SSH_DIR"
: > "${AUTHORIZED_KEYS}.tmp"
if [[ -f "$AUTHORIZED_KEYS" && "$PRESERVE_EXISTING_AUTH_KEYS" == "true" ]]; then
  echo "🧷 Preserving existing keys from $AUTHORIZED_KEYS"
  tr '\r' '\n' < "$AUTHORIZED_KEYS" | sed '/^[[:space:]]*$/d' >> "${AUTHORIZED_KEYS}.tmp"
fi
for param in "${PUBLIC_KEY_PARAMS[@]}"; do
  val="$(aws ssm get-parameter --name "$param" --with-decryption --region "$REGION" \
         --query 'Parameter.Value' --output text 2>/dev/null || true)"
  if [[ -n "$val" && "$val" != "None" ]] && echo "$val" | grep -Eq '^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp256) '; then
    echo "$val" >> "${AUTHORIZED_KEYS}.tmp"; echo "   ➕ Added key from $param"
  else
    echo "   ⚠️  $param: missing/invalid"
  fi
done
if [[ -s "${AUTHORIZED_KEYS}.tmp" ]]; then
  sort -u "${AUTHORIZED_KEYS}.tmp" > "$AUTHORIZED_KEYS"
  rm -f "${AUTHORIZED_KEYS}.tmp"
  chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS"; chmod 600 "$AUTHORIZED_KEYS"
  echo "✅ Installed $(wc -l < "$AUTHORIZED_KEYS") keys"
else
  rm -f "${AUTHORIZED_KEYS}.tmp" || true
  echo "⚠️  No valid keys written to $AUTHORIZED_KEYS"
fi

# ---------- socat forwarder (systemd) ----------
echo "🔁 Installing socat forwarder $FORWARD_PORT → $TARGET_HOST:$TARGET_PORT"
mkdir -p /etc/socat

# Env file used by the unit
cat >/etc/socat/mysql-forward.env <<EOF
FORWARD_PORT=$FORWARD_PORT
TARGET_HOST=$TARGET_HOST
TARGET_PORT=$TARGET_PORT
EOF

# Systemd unit with:
#  - DNS wait
#  - Self-loop guard (refuse if TARGET_HOST resolves to this instance)
#  - Fast backend connect timeout
cat >/etc/systemd/system/socat-mysql.service <<'EOF'
[Unit]
Description=Forward port to RDS endpoint via socat
Wants=network-online.target
After=network-online.target

[Service]
EnvironmentFile=/etc/socat/mysql-forward.env

# 1) Wait for DNS
ExecStartPre=/bin/sh -c "for i in $(seq 1 30); do getent hosts \"$TARGET_HOST\" && exit 0; sleep 2; done; echo \"DNS not resolved for $TARGET_HOST\"; exit 1"

# 2) Self-loop guard: if TARGET_HOST resolves to this instance, refuse to start
ExecStartPre=/bin/sh -c '\
  dest=$(getent ahostsv4 "$TARGET_HOST" | awk "{print \$1; exit}"); \
  my_priv=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 || true); \
  my_pub=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || true); \
  echo "socat-mysql: TARGET_HOST $TARGET_HOST -> ${dest:-<none>}"; \
  if [ -z "$dest" ]; then echo "socat-mysql: No A record for $TARGET_HOST"; exit 1; fi; \
  if [ "$dest" = "$my_priv" ] || { [ -n "$my_pub" ] && [ "$dest" = "$my_pub" ]; }; then \
    echo "socat-mysql: Refusing to start: TARGET_HOST resolves to this instance ($dest). This would create a loop."; \
    exit 1; \
  fi'

# Listener with backlog & TCP options; backend with fast timeout
ExecStart=/bin/sh -c "/usr/bin/socat \
  TCP-LISTEN:$FORWARD_PORT,reuseaddr,fork,backlog=128,nodelay,keepalive \
  TCP:$TARGET_HOST:$TARGET_PORT,connect-timeout=5,nodelay,keepalive"

Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now socat-mysql
systemctl status --no-pager socat-mysql || true

echo "🧪 Checking listener:"
ss -ltnp | grep ":$FORWARD_PORT" || echo "⚠️ socat not listening yet"

echo "ℹ️ Bastion public IP: ${BASTION_PUBLIC_IP:-<none>}" | tee /etc/motd
echo "ℹ️ Bastion private IP: ${BASTION_PRIVATE_IP:-<none>}" | tee -a /etc/motd
echo "🎉 EC2 provisioning completed at: $(date)"
