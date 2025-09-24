#!/bin/bash
set -e

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a "$LOG_FILE") 2>&1

########################################
# Global Variables
########################################
REGION="eu-west-2"
WP_PATH="/var/www/kuflinkcom"
HTACCESS_FILE="$WP_PATH/.htaccess"
VHOST_CONF="/etc/apache2/sites-available/kuflinkcom.conf"
SSL_VHOST_CONF="/etc/apache2/sites-available/kuflinkcom-le-ssl.conf"

########################################
# Utility Functions
########################################
function safe_wp() {
  wp "$@" --allow-root || echo "⚠️ WP-CLI failed: $*"
}

function patch_wp_https_detection() {
  echo "### Patching wp-config.php to respect X-Forwarded-Proto..."
  PATCH='
if (isset($_SERVER["HTTP_X_FORWARDED_PROTO"]) && $_SERVER["HTTP_X_FORWARDED_PROTO"] === "https") {
    $_SERVER["HTTPS"] = "on";
}'
  if [[ -f "$WP_PATH/wp-config.php" && ! $(grep -F 'HTTP_X_FORWARDED_PROTO' "$WP_PATH/wp-config.php") ]]; then
    cp "$WP_PATH/wp-config.php" "$WP_PATH/wp-config.php.bak"
    awk -v patch="$PATCH" '
      /Happy publishing/ && !done {
        print patch "\n"
        done=1
      }
      { print }
    ' "$WP_PATH/wp-config.php.bak" > "$WP_PATH/wp-config.php"
    echo "✔ HTTPS forwarding patch applied to wp-config.php"
  else
    echo "ℹ️ HTTPS patch already present or wp-config.php missing"
  fi
}

function wait_for_dpkg_lock() {
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "⏳ Waiting for dpkg lock..."
    sleep 3
  done
}

function stop_unattended_upgrades() {
  systemctl stop unattended-upgrades || true
  systemctl disable unattended-upgrades || true
}

function reenable_unattended_upgrades() {
  systemctl enable --now unattended-upgrades
}

function apply_tcp_hardening() {
  sysctl -w net.ipv4.tcp_rfc1337=1
  grep -q "^net.ipv4.tcp_rfc1337=1" /etc/sysctl.conf || echo "net.ipv4.tcp_rfc1337=1" >> /etc/sysctl.conf
}

function harden_apache_server_tokens() {
  sed -i 's/^ServerTokens.*/ServerTokens Prod/' /etc/apache2/conf-available/security.conf || echo "ServerTokens Prod" >> /etc/apache2/conf-available/security.conf
  sed -i 's/^ServerSignature.*/ServerSignature Off/' /etc/apache2/conf-available/security.conf || echo "ServerSignature Off" >> /etc/apache2/conf-available/security.conf
  a2enconf security
  systemctl restart apache2
}

function install_php_apache() {
  apt update -y
  add-apt-repository ppa:ondrej/php -y || true
  apt install -y php8.2 php8.2-cli php8.2-mysql php8.2-curl php8.2-xml php8.2-mbstring php8.2-zip php8.2-gd libapache2-mod-php8.2
  update-alternatives --set php /usr/bin/php8.2
  a2dismod php8.3 || true
  a2enmod php8.2
  systemctl restart apache2
}

function install_wp_cli() {
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
}

function search_replace_wp_urls() {
  if [[ -f "$WP_PATH/wp-config.php" ]]; then
    safe_wp search-replace 'https://www.kuflink.com' 'https://brickfin.co.uk' --path=$WP_PATH
  fi
}

function install_plugins_and_updates() {
  if [[ -f "$WP_PATH/wp-config.php" ]]; then
    safe_wp plugin install disable-xml-rpc-pingback --activate --path=$WP_PATH
    CURRENT_VERSION=$(wp plugin get forminator --field=version --path=$WP_PATH --allow-root || echo "not_installed")
    if [[ "$CURRENT_VERSION" != "not_installed" ]]; then
      safe_wp plugin update forminator --path=$WP_PATH
    fi
  fi
}

function disable_directory_listing() {
  grep -q "^Options -Indexes" "$HTACCESS_FILE" || sed -i '1iOptions -Indexes' "$HTACCESS_FILE"
}

function install_aws_cli() {
  command -v aws >/dev/null || {
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install
  }
}

function fetch_ec2_metadata() {
  TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
  INSTANCE_NAME=$(aws ec2 describe-tags --region "$REGION" --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)
}

function create_wp_user_from_ssm() {
  WP_USERNAME=$(aws ssm get-parameter --name "/ec2/wordpress/WP_USERNAME" --with-decryption --region "$REGION" --query "Parameter.Value" --output text)
  WP_PASSWORD=$(aws ssm get-parameter --name "/ec2/wordpress/WP_PASSWORD" --with-decryption --region "$REGION" --query "Parameter.Value" --output text)
  safe_wp user get "$WP_USERNAME" --path=$WP_PATH || \
  safe_wp user create "$WP_USERNAME" "$WP_USERNAME@kuflink.com" --user_pass="$WP_PASSWORD" --role=administrator --path=$WP_PATH
}

function update_apache_vhosts() {
  a2enmod headers
  sed -i 's/ServerName kuflink.com/ServerName brickfin.co.uk/' "$VHOST_CONF"
  sed -i 's/ServerAlias www.kuflink.com/ServerAlias www.brickfin.co.uk/' "$VHOST_CONF"
  systemctl restart apache2
}

function install_mysql() {
  command -v mysql >/dev/null || {
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
    DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.29-1_all.deb <<< $'\n'
    apt update -y
    DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
  }
}

function configure_certbot_ssl() {
  apt install -y certbot python3-certbot-apache
  certbot --apache --non-interactive --agree-tos --redirect -m m.iyanda@kuflink.com -d brickfin.co.uk -d www.brickfin.co.uk || true
}

function run_health_check() {
  sleep 10
  SSM_STATUS=$(systemctl is-active snap.amazon-ssm-agent.amazon-ssm-agent)
  CW_STATUS=$(systemctl is-active amazon-cloudwatch-agent)
  COLLECTD_STATUS=$(systemctl is-active collectd)

  if [[ "$SSM_STATUS" == "active" && "$CW_STATUS" == "active" && "$COLLECTD_STATUS" == "active" ]]; then
    echo "Health Check: SUCCESS" > /var/log/instance-health.log
  else
    echo "Health Check: FAILED" > /var/log/instance-health.log
  fi
}

########################################
# EXECUTION ORDER
########################################
stop_unattended_upgrades
wait_for_dpkg_lock
apply_tcp_hardening
harden_apache_server_tokens
install_php_apache
install_wp_cli
search_replace_wp_urls
install_plugins_and_updates
disable_directory_listing
install_aws_cli
fetch_ec2_metadata
create_wp_user_from_ssm
patch_wp_https_detection
update_apache_vhosts
install_mysql
# configure_certbot_ssl
run_health_check
reenable_unattended_upgrades

echo "### All setup complete on boot."
