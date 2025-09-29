# ====================================================================
# UNIQUE TO TEST ENVIRONMENT
# ====================================================================
data "aws_ssm_parameter" "app_key" { name = "/backend/staging-test/APP_KEY" }
data "aws_ssm_parameter" "twilio_account_sid" { name = "/autostaging/backend/TWILIO_ACCOUNT_SID" }
data "aws_ssm_parameter" "twilio_auth_token" { name = "/autostaging/backend/TWILIO_AUTH_TOKEN" }
data "aws_ssm_parameter" "GET_ADDRESS_LOCATION_KEY" { name = "/backend/staging/GET_ADDRESS_LOCATION_KEY" }

# ====================================================================
# CODE REPO / PIPELINE CONNECTIONS
# ====================================================================
data "aws_ssm_parameter" "kuflink_codestar_connection" { name = "/autostaging/backend/CODESTAR_CONNECTION" }
data "aws_ssm_parameter" "frontend_codestar_connection" { name = "/backend/staging/FRONTEND_CONNECTION" }
data "aws_ssm_parameter" "admin_codestar_connection" { name = "/backend/staging/ADMIN_CONNECTION" }

# ====================================================================
# AWS CREDENTIALS & REGION
# ====================================================================
data "aws_ssm_parameter" "aws_access_key_id" { name = "/backend/staging/AWS_ACCESS_KEY_ID" }
data "aws_ssm_parameter" "aws_secret_access_key" { name = "/backend/staging/AWS_SECRET_ACCESS_KEY" }
data "aws_ssm_parameter" "aws_default_region" { name = "/backend/staging/AWS_DEFAULT_REGION" }
data "aws_ssm_parameter" "aws_region" { name = "/backend/staging/AWS_REGION" }

# ====================================================================
# APPLICATION CORE
# ====================================================================
data "aws_ssm_parameter" "app_env" { name = "/backend/staging/APP_ENV" }
data "aws_ssm_parameter" "app_debug" { name = "/backend/staging/APP_DEBUG" }
data "aws_ssm_parameter" "app_log_level" { name = "/backend/staging/APP_LOG_LEVEL" }
data "aws_ssm_parameter" "app_url" { name = "/backend/staging/APP_URL" }
data "aws_ssm_parameter" "composer_home" { name = "/backend/staging/COMPOSER_HOME" }
data "aws_ssm_parameter" "log_channel" { name = "/backend/staging/LOG_CHANNEL" }
data "aws_ssm_parameter" "local_upload_files_to_s3" { name = "/backend/staging/LOCAL_UPLOAD_FILES_TO_S3" }

# ====================================================================
# QUEUES / SQS
# ====================================================================
data "aws_ssm_parameter" "aws_sqs_driver" { name = "/backend/staging/AWS_SQS_DRIVER" }
data "aws_ssm_parameter" "aws_sqs_prefix" { name = "/backend/staging/AWS_SQS_PREFIX" }
data "aws_ssm_parameter" "aws_sqs_queue" { name = "/backend/staging/AWS_SQS_QUEUE" }
data "aws_ssm_parameter" "aws_sqs_queue_fifo" { name = "/backend/staging/AWS_SQS_QUEUE_FIFO" }
data "aws_ssm_parameter" "aws_sqs_region" { name = "/backend/staging/AWS_SQS_REGION" }
data "aws_ssm_parameter" "queue_connection" { name = "/backend/staging/QUEUE_CONNECTION" }
data "aws_ssm_parameter" "queue_default" { name = "/backend/staging/QUEUE_DEFAULT" }

# ====================================================================
# FEATURE FLAGS / SCHEDULING
# ====================================================================
data "aws_ssm_parameter" "can_run_schedule" { name = "/backend/staging/CAN_RUN_SCHEDULE" }
data "aws_ssm_parameter" "worker_can_run_schedule" { name = "/backend/staging/worker/CAN_RUN_SCHEDULE" }
data "aws_ssm_parameter" "worker_register_worker_routes" { name = "/backend/staging/worker/REGISTER_WORKER_ROUTES" }
data "aws_ssm_parameter" "register_worker_routes" { name = "/backend/staging/web/REGISTER_WORKER_ROUTES" }
data "aws_ssm_parameter" "telescope_enabled" { name = "/backend/staging/TELESCOPE_ENABLED" }

# ====================================================================
# EMAIL / MANDRILL / SES / MAILER
# ====================================================================
data "aws_ssm_parameter" "mandrill_secret" { name = "/backend/staging/MANDRILL_SECRET" }
data "aws_ssm_parameter" "mandrill_apikey" { name = "/backend/staging/MANDRILL_APIKEY" }
data "aws_ssm_parameter" "mail_driver" { name = "/backend/staging/MAIL_DRIVER" }
data "aws_ssm_parameter" "mail_encryption" { name = "/backend/staging/MAIL_ENCRYPTION" }
data "aws_ssm_parameter" "mail_host" { name = "/backend/staging/MAIL_HOST" }
data "aws_ssm_parameter" "mail_password" { name = "/backend/staging/MAIL_PASSWORD" }
data "aws_ssm_parameter" "mail_port" { name = "/backend/staging/MAIL_PORT" }
data "aws_ssm_parameter" "mail_username" { name = "/backend/staging/MAIL_USERNAME" }
data "aws_ssm_parameter" "send_local_emails" { name = "/backend/staging/SEND_LOCAL_EMAILS" }
data "aws_ssm_parameter" "ses_key" { name = "/backend/staging/SES_KEY" }
data "aws_ssm_parameter" "ses_region" { name = "/backend/staging/SES_REGION" }
data "aws_ssm_parameter" "ses_secret" { name = "/backend/staging/SES_SECRET" }

# ====================================================================
# TWILIO
# ====================================================================
data "aws_ssm_parameter" "hubspot_integration" { name = "/backend/staging/HUBSPOT_INTEGRATION" } # (kept grouping separate below for HubSpot)
# Twilio already listed in UNIQUE TO TEST ENVIRONMENT

# ====================================================================
# THIRD-PARTY INTEGRATIONS
# ====================================================================
# Bank of England
data "aws_ssm_parameter" "bank_of_england_api_key" { name = "/backend/staging/BANK_OF_ENGLAND_API_KEY" }
data "aws_ssm_parameter" "bank_of_england_api_url" { name = "/backend/staging/BANK_OF_ENGLAND_API_URL" }

# HubSpot / Intercom
data "aws_ssm_parameter" "hubspot_access_token" { name = "/backend/staging/HUBSPOT_ACCESS_TOKEN" }
data "aws_ssm_parameter" "intercom_integration" { name = "/backend/staging/INTERCOM_INTEGRATION" }

# Dropbox
data "aws_ssm_parameter" "ext_dropbox_access_token" { name = "/backend/staging/EXT_DROPBOX_ACCESS_TOKEN" }
data "aws_ssm_parameter" "ext_dropbox_client_id" { name = "/backend/staging/EXT_DROPBOX_CLIENT_ID" }
data "aws_ssm_parameter" "ext_dropbox_client_secret" { name = "/backend/staging/EXT_DROPBOX_CLIENT_SECRET" }

# Stripe
data "aws_ssm_parameter" "connected_stripe_account_id" { name = "/backend/staging/CONNECTED_STRIPE_ACCOUNT_ID" }
data "aws_ssm_parameter" "stripe_publishable_key" { name = "/backend/staging/STRIPE_PUBLISHABLE_KEY" }
data "aws_ssm_parameter" "stripe_secret_key" { name = "/backend/staging/STRIPE_SECRET_KEY" }

# DocuSign
data "aws_ssm_parameter" "docusign_account_id" { name = "/backend/staging/DOCUSIGN_ACCOUNT_ID" }
data "aws_ssm_parameter" "docusign_api_url" { name = "/backend/staging/DOCUSIGN_API_URL" }
data "aws_ssm_parameter" "docusign_base_url" { name = "/backend/staging/DOCUSIGN_BASE_URL" }
data "aws_ssm_parameter" "docusign_client_id" { name = "/backend/staging/DOCUSIGN_CLIENT_ID" }
data "aws_ssm_parameter" "docusign_client_secret" { name = "/backend/staging/DOCUSIGN_CLIENT_SECRET" }

# Onfido
data "aws_ssm_parameter" "onfido_mob_api_key" { name = "/backend/staging/ONFIDO_MOB_API_KEY" }
data "aws_ssm_parameter" "onfido_mob_application_id" { name = "/backend/staging/ONFIDO_MOB_APPLICATION_ID" }
data "aws_ssm_parameter" "onfido_web_api_key" { name = "/backend/staging/ONFIDO_WEB_API_KEY" }

# Mangopay
data "aws_ssm_parameter" "mangopay_client" { name = "/backend/staging/MANGOPAY_CLIENT" }
data "aws_ssm_parameter" "mangopay_max_funds_per_transaction_for_topup" { name = "/backend/staging/MANGOPAY_MAX_FUNDS_PER_TRANSACTION_FOR_TOPUP" }
data "aws_ssm_parameter" "mangopay_passphrase" { name = "/backend/staging/MANGOPAY_PASSPHRASE" }
data "aws_ssm_parameter" "mangopay_redirect_url" { name = "/backend/staging/MANGOPAY_REDIRECT_URL" }
data "aws_ssm_parameter" "mangopay_topup_funds_limit_without_mangopay_aml" { name = "/backend/staging/MANGOPAY_TOPUP_FUNDS_LIMIT_WITHOUT_MANGOPAY_AML" }
data "aws_ssm_parameter" "mangopay_url" { name = "/backend/staging/MANGOPAY_URL" }

# Other external
data "aws_ssm_parameter" "personal_agreement_url" { name = "/backend/staging/PERSONAL_AGREEMENT_URL" }
data "aws_ssm_parameter" "corporate_agreement_url" { name = "/backend/staging/CORPORATE_AGREEMENT_URL" }

# ====================================================================
# BROADCAST / CACHE
# ====================================================================
data "aws_ssm_parameter" "broadcast_driver" { name = "/backend/staging/BROADCAST_DRIVER" }
data "aws_ssm_parameter" "cache_driver" { name = "/backend/staging/CACHE_DRIVER" }

# ====================================================================
# SESSION
# ====================================================================
data "aws_ssm_parameter" "session_driver" { name = "/backend/staging/SESSION_DRIVER" }
data "aws_ssm_parameter" "session_secure_cookie" { name = "/backend/staging/SESSION_SECURE_COOKIE" }

# ====================================================================
# ACTIVITY LOGGER
# ====================================================================
data "aws_ssm_parameter" "activity_logger_db_connection" { name = "/backend/staging/ACTIVITY_LOGGER_DB_CONNECTION" }
data "aws_ssm_parameter" "activity_logger_enabled" { name = "/backend/staging/ACTIVITY_LOGGER_ENABLED" }

# ====================================================================
# DATABASE (CONNECTION NAMES & META)
# ====================================================================
# data "aws_ssm_parameter" "db_connection_audit_name"   { name = "/backend/staging/DB_CONNECTION_AUDIT_NAME" }
# data "aws_ssm_parameter" "db_connection_read_only"    { name = "/backend/staging/DB_CONNECTION_READONLY" }
# data "aws_ssm_parameter" "db_connection_staging_name" { name = "/backend/staging/DB_CONNECTION_STAGING_NAME" }
# data "aws_ssm_parameter" "db_subnet_group_name"       { name = "db_subnet_group_name" }

# ====================================================================
# DATABASE (AUDIT)
# ====================================================================
# data "aws_ssm_parameter" "db_database_audit" { name = "/backend/staging/DB_DATABASE_AUDIT" }
# data "aws_ssm_parameter" "db_host_audit"     { name = "/backend/staging/DB_HOST_AUDIT" }
# data "aws_ssm_parameter" "db_password_audit" { name = "/backend/staging/DB_PASSWORD_AUDIT" }
# data "aws_ssm_parameter" "db_port_audit"     { name = "/backend/staging/DB_PORT_AUDIT" }
# data "aws_ssm_parameter" "db_username_audit" { name = "/backend/staging/DB_USERNAME_AUDIT" }

# ====================================================================
# DATABASE (READONLY)
# ====================================================================
# data "aws_ssm_parameter" "db_database_readonly" { name = "/backend/staging/DB_DATABASE_READONLY" }

# data "aws_ssm_parameter" "db_password_readonly" { name = "/backend/staging/DB_PASSWORD_READONLY" }
# data "aws_ssm_parameter" "db_port_readonly"     { name = "/backend/staging/DB_PORT_READONLY" }
# data "aws_ssm_parameter" "db_username_readonly" { name = "/backend/staging/DB_USERNAME_READONLY" }

# ====================================================================
# DATABASE (STAGING)
# ====================================================================
# data "aws_ssm_parameter" "db_database_staging" { name = "/backend/staging/DB_DATABASE_STAGING" }
# data "aws_ssm_parameter" "db_host_staging"     { name = "/backend/staging/DB_HOST_STAGING" }
# data "aws_ssm_parameter" "db_password_staging" { name = "/backend/staging/DB_PASSWORD_STAGING" }
# data "aws_ssm_parameter" "db_port_staging"     { name = "/backend/staging/DB_PORT_STAGING" }
# data "aws_ssm_parameter" "db_username_staging" { name = "/backend/staging/DB_USERNAME_STAGING" }

# ====================================================================
# DATABASE (STAGING TESTING)
# ====================================================================
# data "aws_ssm_parameter" "db_database_staging_testing" { name = "/backend/staging/DB_DATABASE_STAGING_TESTING" }
# data "aws_ssm_parameter" "db_host_staging_testing"     { name = "/backend/staging/DB_HOST_STAGING_TESTING" }
# data "aws_ssm_parameter" "db_port_staging_testing"     { name = "/backend/staging/DB_PORT_STAGING_TESTING" }
# data "aws_ssm_parameter" "db_username_staging_testing" { name = "/backend/staging/DB_USERNAME_STAGING_TESTING" }
