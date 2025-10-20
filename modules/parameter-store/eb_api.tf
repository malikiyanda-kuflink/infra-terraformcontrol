# ===================================================================
# ENVIRONMENT VARIABLE PARAMETER STORE
# ===================================================================

data "aws_ssm_parameter" "api_repo" { name = "/kuflink/${var.environment}/api_repo" }
data "aws_ssm_parameter" "api_domain" { name = "/kuflink/${var.environment}/api_domain" }
data "aws_ssm_parameter" "api_url" { name = "/kuflink/${var.environment}/api_url" }
data "aws_ssm_parameter" "worker_queue_name" { name = "/kuflink/${var.environment}/worker-queue-name" }


# -------------------------------------------------------------------
# ACTIVITY LOGGER
# -------------------------------------------------------------------
data "aws_ssm_parameter" "activity_logger_db_connection" { name = "/backend/${var.environment}/ACTIVITY_LOGGER_DB_CONNECTION" }
data "aws_ssm_parameter" "activity_logger_enabled" { name = "/backend/${var.environment}/ACTIVITY_LOGGER_ENABLED" }

# -------------------------------------------------------------------
# APPLICATION CORE
# -------------------------------------------------------------------
data "aws_ssm_parameter" "app_debug" { name = "/backend/${var.environment}/APP_DEBUG" }
data "aws_ssm_parameter" "app_env" { name = "/backend/${var.environment}/APP_ENV" }
data "aws_ssm_parameter" "app_key" { name = "/backend/${var.environment}/APP_KEY" }
data "aws_ssm_parameter" "app_log_level" { name = "/backend/${var.environment}/APP_LOG_LEVEL" }
data "aws_ssm_parameter" "app_url" { name = "/backend/${var.environment}/APP_URL" }

# -------------------------------------------------------------------
# AWS CREDENTIALS & REGION
# -------------------------------------------------------------------
data "aws_ssm_parameter" "aws_access_key_id" { name = "/backend/${var.environment}/AWS_ACCESS_KEY_ID" }
data "aws_ssm_parameter" "aws_default_region" { name = "/backend/${var.environment}/AWS_DEFAULT_REGION" }
data "aws_ssm_parameter" "aws_region" { name = "/backend/${var.environment}/AWS_REGION" }
data "aws_ssm_parameter" "aws_secret_access_key" { name = "/backend/${var.environment}/AWS_SECRET_ACCESS_KEY" }

# -------------------------------------------------------------------
# AWS SQS / QUEUES
# -------------------------------------------------------------------
data "aws_ssm_parameter" "aws_sqs_driver" { name = "/backend/${var.environment}/AWS_SQS_DRIVER" }
data "aws_ssm_parameter" "aws_sqs_prefix" { name = "/backend/${var.environment}/AWS_SQS_PREFIX" }
data "aws_ssm_parameter" "aws_sqs_queue" { name = "/backend/${var.environment}/AWS_SQS_QUEUE" }
data "aws_ssm_parameter" "aws_sqs_region" { name = "/backend/${var.environment}/AWS_SQS_REGION" }

# -------------------------------------------------------------------
# BANK OF ENGLAND
# -------------------------------------------------------------------
data "aws_ssm_parameter" "bank_of_england_api_key" { name = "/backend/${var.environment}/BANK_OF_ENGLAND_API_KEY" }
data "aws_ssm_parameter" "bank_of_england_api_url" { name = "/backend/${var.environment}/BANK_OF_ENGLAND_API_URL" }

# -------------------------------------------------------------------
# BROADCAST / CACHE
# -------------------------------------------------------------------
data "aws_ssm_parameter" "broadcast_driver" { name = "/backend/${var.environment}/BROADCAST_DRIVER" }
data "aws_ssm_parameter" "cache_driver" { name = "/backend/${var.environment}/CACHE_DRIVER" }

# -------------------------------------------------------------------
# FEATURE FLAGS / SCHEDULING
# -------------------------------------------------------------------
data "aws_ssm_parameter" "can_run_schedule" { name = "/backend/${var.environment}/CAN_RUN_SCHEDULE" }
data "aws_ssm_parameter" "register_worker_routes" { name = "/backend/${var.environment}/REGISTER_WORKER_ROUTES" }

# -------------------------------------------------------------------
# COMPOSER
# -------------------------------------------------------------------
data "aws_ssm_parameter" "composer_home" { name = "/backend/${var.environment}/COMPOSER_HOME" }

# -------------------------------------------------------------------
# STRIPE / PAYMENTS
# -------------------------------------------------------------------
data "aws_ssm_parameter" "connected_stripe_account_id" { name = "/backend/${var.environment}/CONNECTED_STRIPE_ACCOUNT_ID" }
data "aws_ssm_parameter" "stripe_publishable_key" { name = "/backend/${var.environment}/STRIPE_PUBLISHABLE_KEY" }
data "aws_ssm_parameter" "stripe_secret_key" { name = "/backend/${var.environment}/STRIPE_SECRET_KEY" }

# -------------------------------------------------------------------
# CORPORATE AGREEMENT
# -------------------------------------------------------------------
data "aws_ssm_parameter" "corporate_agreement_url" { name = "/backend/${var.environment}/CORPORATE_AGREEMENT_URL" }

# -------------------------------------------------------------------
# DATABASE
# -------------------------------------------------------------------
# data "aws_ssm_parameter" "db_connection"    { name = "/backend/${var.environment}/DB_CONNECTION" }
# data "aws_ssm_parameter" "db_database"      { name = "/backend/${var.environment}/DB_DATABASE" }
# data "aws_ssm_parameter" "db_host"          { name = "/backend/${var.environment}/DB_HOST" }
# data "aws_ssm_parameter" "db_host_readonly" { name = "/backend/${var.environment}/DB_HOST_READONLY" }
# data "aws_ssm_parameter" "db_password"      { name = "/backend/${var.environment}/DB_PASSWORD" }
# data "aws_ssm_parameter" "db_port"          { name = "/backend/${var.environment}/DB_PORT" }
# data "aws_ssm_parameter" "db_username"      { name = "/backend/${var.environment}/DB_USERNAME" }

# -------------------------------------------------------------------
# DOCUSIGN
# -------------------------------------------------------------------
data "aws_ssm_parameter" "docusign_account_id" { name = "/backend/${var.environment}/DOCUSIGN_ACCOUNT_ID" }
data "aws_ssm_parameter" "docusign_api_url" { name = "/backend/${var.environment}/DOCUSIGN_API_URL" }
data "aws_ssm_parameter" "docusign_base_url" { name = "/backend/${var.environment}/DOCUSIGN_BASE_URL" }
data "aws_ssm_parameter" "docusign_client_id" { name = "/backend/${var.environment}/DOCUSIGN_CLIENT_ID" }
data "aws_ssm_parameter" "docusign_client_secret" { name = "/backend/${var.environment}/DOCUSIGN_CLIENT_SECRET" }

# -------------------------------------------------------------------
# THIRD PARTY KEYS
# -------------------------------------------------------------------
data "aws_ssm_parameter" "get_address_location_key" { name = "/backend/${var.environment}/GET_ADDRESS_LOCATION_KEY" }

# -------------------------------------------------------------------
# HUBSPOT / INTERCOM
# -------------------------------------------------------------------
data "aws_ssm_parameter" "hubspot_access_token" { name = "/backend/${var.environment}/HUBSPOT_ACCESS_TOKEN" }
data "aws_ssm_parameter" "intercom_integration" { name = "/backend/${var.environment}/INTERCOM_INTEGRATION" }

# -------------------------------------------------------------------
# LOGGING
# -------------------------------------------------------------------
data "aws_ssm_parameter" "log_channel" { name = "/backend/${var.environment}/LOG_CHANNEL" }

# -------------------------------------------------------------------
# MAIL / SES / MANDRILL
# -------------------------------------------------------------------
data "aws_ssm_parameter" "mail_driver" { name = "/backend/${var.environment}/MAIL_DRIVER" }
data "aws_ssm_parameter" "mail_port" { name = "/backend/${var.environment}/MAIL_PORT" }
data "aws_ssm_parameter" "mail_host" { name = "/backend/${var.environment}/MAIL_HOST" }
data "aws_ssm_parameter" "mail_encryption" { name = "/backend/${var.environment}/MAIL_ENCRYPTION" }
data "aws_ssm_parameter" "mandrill_apikey" { name = "/backend/${var.environment}/MANDRILL_APIKEY" }
data "aws_ssm_parameter" "mandrill_secret" { name = "/backend/${var.environment}/MANDRILL_SECRET" }
data "aws_ssm_parameter" "send_local_emails" { name = "/backend/${var.environment}/SEND_LOCAL_EMAILS" }
data "aws_ssm_parameter" "ses_key" { name = "/backend/${var.environment}/SES_KEY" }
data "aws_ssm_parameter" "ses_region" { name = "/backend/${var.environment}/SES_REGION" }
data "aws_ssm_parameter" "ses_secret" { name = "/backend/${var.environment}/SES_SECRET" }

# -------------------------------------------------------------------
# MANGOPAY
# -------------------------------------------------------------------
data "aws_ssm_parameter" "mangopay_client" { name = "/backend/${var.environment}/MANGOPAY_CLIENT" }
data "aws_ssm_parameter" "mangopay_max_funds_per_transaction_for_topup" { name = "/backend/${var.environment}/MANGOPAY_MAX_FUNDS_PER_TRANSACTION_FOR_TOPUP" }
data "aws_ssm_parameter" "mangopay_passphrase" { name = "/backend/${var.environment}/MANGOPAY_PASSPHRASE" }
data "aws_ssm_parameter" "mangopay_redirect_url" { name = "/backend/${var.environment}/MANGOPAY_REDIRECT_URL" }
data "aws_ssm_parameter" "mangopay_topup_funds_limit_without_mangopay_aml" { name = "/backend/${var.environment}/MANGOPAY_TOPUP_FUNDS_LIMIT_WITHOUT_MANGOPAY_AML" }
data "aws_ssm_parameter" "mangopay_url" { name = "/backend/${var.environment}/MANGOPAY_URL" }

# -------------------------------------------------------------------
# ONFIDO
# -------------------------------------------------------------------
data "aws_ssm_parameter" "onfido_mob_api_key" { name = "/backend/${var.environment}/ONFIDO_MOB_API_KEY" }
data "aws_ssm_parameter" "onfido_mob_application_id" { name = "/backend/${var.environment}/ONFIDO_MOB_APPLICATION_ID" }
data "aws_ssm_parameter" "onfido_web_api_key" { name = "/backend/${var.environment}/ONFIDO_WEB_API_KEY" }
data "aws_ssm_parameter" "onfido_regular_aml" { name = "/backend/${var.environment}/ONFIDO_REGULAR_AML" }

# -------------------------------------------------------------------
# AGREEMENTS
# -------------------------------------------------------------------
data "aws_ssm_parameter" "personal_agreement_url" { name = "/backend/${var.environment}/PERSONAL_AGREEMENT_URL" }

# -------------------------------------------------------------------
# QUEUES
# -------------------------------------------------------------------
data "aws_ssm_parameter" "queue_connection" { name = "/backend/${var.environment}/QUEUE_CONNECTION" }
data "aws_ssm_parameter" "queue_default" { name = "/backend/${var.environment}/QUEUE_DEFAULT" }

# -------------------------------------------------------------------
# REDIS
# -------------------------------------------------------------------
# data "aws_ssm_parameter" "redis_client"   { name = "/backend/${var.environment}/REDIS_CLIENT" }
# data "aws_ssm_parameter" "redis_host"     { name = "/backend/${var.environment}/REDIS_HOST" }
# data "aws_ssm_parameter" "redis_password" { name = "/backend/${var.environment}/REDIS_PASSWORD" }
# data "aws_ssm_parameter" "redis_port"     { name = "/backend/${var.environment}/REDIS_PORT" }

# -------------------------------------------------------------------
# REGION (lowercase)
# -------------------------------------------------------------------
data "aws_ssm_parameter" "region_lower" { name = "/backend/${var.environment}/region" }

# -------------------------------------------------------------------
# SESSION
# -------------------------------------------------------------------
data "aws_ssm_parameter" "session_driver" { name = "/backend/${var.environment}/SESSION_DRIVER" }
data "aws_ssm_parameter" "session_secure_cookie" { name = "/backend/${var.environment}/SESSION_SECURE_COOKIE" }

# -------------------------------------------------------------------
# TELESCOPE
# -------------------------------------------------------------------
data "aws_ssm_parameter" "telescope_enabled" { name = "/backend/${var.environment}/TELESCOPE_ENABLED" }

# -------------------------------------------------------------------
# TWILIO
# -------------------------------------------------------------------
data "aws_ssm_parameter" "twilio_account_sid" { name = "/backend/${var.environment}/TWILIO_ACCOUNT_SID" }
data "aws_ssm_parameter" "twilio_auth_token" { name = "/backend/${var.environment}/TWILIO_AUTH_TOKEN" }


