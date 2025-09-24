#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a "$LOG_FILE") 2>&1

REGION="eu-west-2"
SSM_KEY_NAME="/kuflink/ssh/staging_pem"
SSH_DIR="/home/ec2-user/.ssh"
PEM_FILE="${SSH_DIR}/staging.pem"
CONNECTION_SCRIPT="/home/ec2-user/connection_test.sh"

# --- FUNCTIONS ---

install_prereqs() {
  echo "📦 Installing prerequisites..."
  dnf install -y awscli jq mariadb105
}

setup_ssh_key() {
  echo "🔐 Setting up SSH key from SSM..."
  mkdir -p "$SSH_DIR"
  chown ec2-user:ec2-user "$SSH_DIR"
  chmod 700 "$SSH_DIR"

  aws ssm get-parameter \
    --name "$SSM_KEY_NAME" \
    --with-decryption \
    --region "$REGION" \
    --query Parameter.Value \
    --output text > "$PEM_FILE"

  chown ec2-user:ec2-user "$PEM_FILE"
  chmod 400 "$PEM_FILE"
  echo "✅ SSH key setup complete"
}

deploy_connection_script() {
  echo "🚀 Deploying secure RDS and Redshift connection test script..."

  echo '#!/bin/bash' > "$CONNECTION_SCRIPT"
  echo 'REGION="eu-west-2"' >> "$CONNECTION_SCRIPT"

  echo 'echo "🔐 Fetching RDS credentials from SSM..."' >> "$CONNECTION_SCRIPT"
  echo 'RDS_ENDPOINT=$(aws ssm get-parameter --name "/backend/staging-test/DB_HOST" --region "$REGION" --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'RDS_PORT=$(aws ssm get-parameter --name "/backend/staging-test/DB_PORT" --region "$REGION" --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'RDS_USER=$(aws ssm get-parameter --name "/backend/staging-test/DB_USERNAME" --region "$REGION" --with-decryption --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'RDS_DB=$(aws ssm get-parameter --name "/backend/staging-test/DB_DATABASE" --region "$REGION" --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'RDS_PASSWORD=$(aws ssm get-parameter --name "/backend/staging-test/DB_PASSWORD" --region "$REGION" --with-decryption --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"

  echo 'echo "🔍 Testing RDS connection..."' >> "$CONNECTION_SCRIPT"
  echo 'if mysql -h "$RDS_ENDPOINT" -P "$RDS_PORT" -u "$RDS_USER" -p"$RDS_PASSWORD" -e "SHOW DATABASES;" "$RDS_DB"; then' >> "$CONNECTION_SCRIPT"
  echo '  echo "✅ RDS connection successful to $RDS_DB at $RDS_ENDPOINT:$RDS_PORT"' >> "$CONNECTION_SCRIPT"
  echo '  RDS_STATUS="Success"' >> "$CONNECTION_SCRIPT"
  echo 'else' >> "$CONNECTION_SCRIPT"
  echo '  echo "❌ RDS connection failed"' >> "$CONNECTION_SCRIPT"
  echo '  RDS_STATUS="Failed"' >> "$CONNECTION_SCRIPT"
  echo 'fi' >> "$CONNECTION_SCRIPT"

  echo '' >> "$CONNECTION_SCRIPT"
  echo 'echo "🔐 Fetching Redshift credentials from SSM..."' >> "$CONNECTION_SCRIPT"
  echo 'REDSHIFT_HOST=$(aws ssm get-parameter --name "/backend/staging-test/REDSHIFT_HOST" --region "$REGION" --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'REDSHIFT_PORT=$(aws ssm get-parameter --name "/backend/staging-test/REDSHIFT_PORT" --region "$REGION" --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'REDSHIFT_USER=$(aws ssm get-parameter --name "/backend/staging-test/REDSHIFT_USERNAME" --region "$REGION" --with-decryption --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'REDSHIFT_DB=$(aws ssm get-parameter --name "/backend/staging-test/REDSHIFT_DATABASE" --region "$REGION" --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'REDSHIFT_PASSWORD=$(aws ssm get-parameter --name "/backend/staging-test/REDSHIFT_PASSWORD" --region "$REGION" --with-decryption --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"

  echo 'echo "🔍 Testing Redshift connection..."' >> "$CONNECTION_SCRIPT"
  echo 'PGPASSWORD="$REDSHIFT_PASSWORD" psql -h "$REDSHIFT_HOST" -p "$REDSHIFT_PORT" -U "$REDSHIFT_USER" -d "$REDSHIFT_DB" -c "SELECT current_database();"' >> "$CONNECTION_SCRIPT"
  echo 'if [ $? -eq 0 ]; then' >> "$CONNECTION_SCRIPT"
  echo '  echo "✅ Redshift connection successful to $REDSHIFT_DB at $REDSHIFT_HOST:$REDSHIFT_PORT"' >> "$CONNECTION_SCRIPT"
  echo '  REDSHIFT_STATUS="Success"' >> "$CONNECTION_SCRIPT"
  echo 'else' >> "$CONNECTION_SCRIPT"
  echo '  echo "❌ Redshift connection failed (non-blocking)"' >> "$CONNECTION_SCRIPT"
  echo '  REDSHIFT_STATUS="Failed"' >> "$CONNECTION_SCRIPT"
  echo 'fi' >> "$CONNECTION_SCRIPT"

  echo '' >> "$CONNECTION_SCRIPT"
  echo 'echo "🔐 Fetching DEPRECATED RDS credentials from SSM..."' >> "$CONNECTION_SCRIPT"
  echo 'DEPRECATED_ENDPOINT=$(aws ssm get-parameter --name "/backend/staging-test/DEPRECATED_DB_HOST" --region "$REGION" --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'DEPRECATED_PORT=$(aws ssm get-parameter --name "/backend/staging-test/DB_PORT" --region "$REGION" --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'DEPRECATED_USER=$(aws ssm get-parameter --name "/backend/staging-test/DB_USERNAME" --region "$REGION" --with-decryption --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'DEPRECATED_DB=$(aws ssm get-parameter --name "/backend/staging-test/DB_DATABASE" --region "$REGION" --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"
  echo 'DEPRECATED_PASSWORD=$(aws ssm get-parameter --name "/backend/staging-test/DB_PASSWORD" --region "$REGION" --with-decryption --query "Parameter.Value" --output text)' >> "$CONNECTION_SCRIPT"

  echo 'echo "[client]" > ~/.my.cnf.deprecated' >> "$CONNECTION_SCRIPT"
  echo 'echo "user=$DEPRECATED_USER" >> ~/.my.cnf.deprecated' >> "$CONNECTION_SCRIPT"
  echo 'echo "password=$DEPRECATED_PASSWORD" >> ~/.my.cnf.deprecated' >> "$CONNECTION_SCRIPT"
  echo 'chmod 600 ~/.my.cnf.deprecated' >> "$CONNECTION_SCRIPT"

  echo 'echo "🔍 Testing DEPRECATED RDS connection..."' >> "$CONNECTION_SCRIPT"
  echo 'if mysql --defaults-extra-file=~/.my.cnf.deprecated -h "$DEPRECATED_ENDPOINT" -P "$DEPRECATED_PORT" -e "SHOW DATABASES;" "$DEPRECATED_DB"; then' >> "$CONNECTION_SCRIPT"
  echo '  echo "✅ Deprecated RDS connection successful to $DEPRECATED_DB at $DEPRECATED_ENDPOINT:$DEPRECATED_PORT"' >> "$CONNECTION_SCRIPT"
  echo '  DEPRECATED_STATUS="Success"' >> "$CONNECTION_SCRIPT"
  echo 'else' >> "$CONNECTION_SCRIPT"
  echo '  echo "❌ Deprecated RDS connection failed"' >> "$CONNECTION_SCRIPT"
  echo '  DEPRECATED_STATUS="Failed"' >> "$CONNECTION_SCRIPT"
  echo 'fi' >> "$CONNECTION_SCRIPT"

  echo '' >> "$CONNECTION_SCRIPT"
  echo 'echo "📊 Connection Test Summary:"' >> "$CONNECTION_SCRIPT"
  echo 'echo "----------------------------"' >> "$CONNECTION_SCRIPT"
  echo 'echo "✅ RDS:            ${RDS_STATUS:-Unknown}"' >> "$CONNECTION_SCRIPT"
  echo 'echo "✅ Redshift:       ${REDSHIFT_STATUS:-Unknown}"' >> "$CONNECTION_SCRIPT"
  echo 'echo "✅ Deprecated RDS: ${DEPRECATED_STATUS:-Unknown}"' >> "$CONNECTION_SCRIPT"

  chmod +x "$CONNECTION_SCRIPT"
  chown "$USERNAME:$USERNAME" "$CONNECTION_SCRIPT"
  echo "✅ Connection test script deployed at: $CONNECTION_SCRIPT"
}

# --- MAIN EXECUTION ---

install_prereqs
setup_ssh_key
deploy_connection_script

echo "🎉 EC2 provisioning completed at: $(date)"
