output "eb_api" {
  description = "Map of all backend environment variables"
  value = {
    # API Configuration
    API_REPO          = data.aws_ssm_parameter.api_repo.value
    API_DOMAIN        = data.aws_ssm_parameter.api_domain.value
    API_URL           = data.aws_ssm_parameter.api_url.value
    WORKER_QUEUE_NAME = data.aws_ssm_parameter.worker_queue_name.value


    # Activity Logger
    ACTIVITY_LOGGER_DB_CONNECTION = data.aws_ssm_parameter.activity_logger_db_connection.value
    ACTIVITY_LOGGER_ENABLED       = data.aws_ssm_parameter.activity_logger_enabled.value

    # Application Core
    APP_DEBUG     = data.aws_ssm_parameter.app_debug.value
    APP_ENV       = data.aws_ssm_parameter.app_env.value
    APP_KEY       = data.aws_ssm_parameter.app_key.value
    APP_LOG_LEVEL = data.aws_ssm_parameter.app_log_level.value
    APP_URL       = data.aws_ssm_parameter.app_url.value

    # AWS Credentials & Region
    AWS_ACCESS_KEY_ID     = data.aws_ssm_parameter.aws_access_key_id.value
    AWS_DEFAULT_REGION    = data.aws_ssm_parameter.aws_default_region.value
    AWS_REGION            = data.aws_ssm_parameter.aws_region.value
    AWS_SECRET_ACCESS_KEY = data.aws_ssm_parameter.aws_secret_access_key.value

    # AWS SQS / Queues
    AWS_SQS_DRIVER = data.aws_ssm_parameter.aws_sqs_driver.value
    AWS_SQS_PREFIX = data.aws_ssm_parameter.aws_sqs_prefix.value
    AWS_SQS_QUEUE  = data.aws_ssm_parameter.aws_sqs_queue.value
    AWS_SQS_REGION = data.aws_ssm_parameter.aws_sqs_region.value

    # Bank of England
    BANK_OF_ENGLAND_API_KEY = data.aws_ssm_parameter.bank_of_england_api_key.value
    BANK_OF_ENGLAND_API_URL = data.aws_ssm_parameter.bank_of_england_api_url.value

    # Broadcast / Cache
    BROADCAST_DRIVER = data.aws_ssm_parameter.broadcast_driver.value
    CACHE_DRIVER     = data.aws_ssm_parameter.cache_driver.value

    # Feature Flags / Scheduling
    CAN_RUN_SCHEDULE       = data.aws_ssm_parameter.can_run_schedule.value
    REGISTER_WORKER_ROUTES = data.aws_ssm_parameter.register_worker_routes.value

    # Composer
    COMPOSER_HOME = data.aws_ssm_parameter.composer_home.value

    # Stripe / Payments
    CONNECTED_STRIPE_ACCOUNT_ID = data.aws_ssm_parameter.connected_stripe_account_id.value
    STRIPE_PUBLISHABLE_KEY      = data.aws_ssm_parameter.stripe_publishable_key.value
    STRIPE_SECRET_KEY           = data.aws_ssm_parameter.stripe_secret_key.value

    # Corporate Agreement
    CORPORATE_AGREEMENT_URL = data.aws_ssm_parameter.corporate_agreement_url.value

    # DocuSign
    DOCUSIGN_ACCOUNT_ID    = data.aws_ssm_parameter.docusign_account_id.value
    DOCUSIGN_API_URL       = data.aws_ssm_parameter.docusign_api_url.value
    DOCUSIGN_BASE_URL      = data.aws_ssm_parameter.docusign_base_url.value
    DOCUSIGN_CLIENT_ID     = data.aws_ssm_parameter.docusign_client_id.value
    DOCUSIGN_CLIENT_SECRET = data.aws_ssm_parameter.docusign_client_secret.value

    # Third Party Keys
    GET_ADDRESS_LOCATION_KEY = data.aws_ssm_parameter.get_address_location_key.value

    # HubSpot / Intercom
    HUBSPOT_ACCESS_TOKEN = data.aws_ssm_parameter.hubspot_access_token.value
    INTERCOM_INTEGRATION = data.aws_ssm_parameter.intercom_integration.value

    # Logging
    LOG_CHANNEL = data.aws_ssm_parameter.log_channel.value

    # Mail / SES / Mandrill
    MAIL_DRIVER       = data.aws_ssm_parameter.mail_driver.value
    MAIL_PORT         = data.aws_ssm_parameter.mail_port.value
    MAIL_USERNAME     = data.aws_ssm_parameter.mail_username.value
    MAIL_PASSWORD     = data.aws_ssm_parameter.mail_password.value
    MAIL_HOST         = data.aws_ssm_parameter.mail_host.value
    MAIL_ENCRYPTION   = data.aws_ssm_parameter.mail_encryption.value
    MANDRILL_APIKEY   = data.aws_ssm_parameter.mandrill_apikey.value
    MANDRILL_SECRET   = data.aws_ssm_parameter.mandrill_secret.value
    SEND_LOCAL_EMAILS = data.aws_ssm_parameter.send_local_emails.value
    SES_KEY           = data.aws_ssm_parameter.ses_key.value
    SES_REGION        = data.aws_ssm_parameter.ses_region.value
    SES_SECRET        = data.aws_ssm_parameter.ses_secret.value

    # MangoPay
    MANGOPAY_CLIENT                                 = data.aws_ssm_parameter.mangopay_client.value
    MANGOPAY_MAX_FUNDS_PER_TRANSACTION_FOR_TOPUP    = data.aws_ssm_parameter.mangopay_max_funds_per_transaction_for_topup.value
    MANGOPAY_PASSPHRASE                             = data.aws_ssm_parameter.mangopay_passphrase.value
    MANGOPAY_REDIRECT_URL                           = data.aws_ssm_parameter.mangopay_redirect_url.value
    MANGOPAY_TOPUP_FUNDS_LIMIT_WITHOUT_MANGOPAY_AML = data.aws_ssm_parameter.mangopay_topup_funds_limit_without_mangopay_aml.value
    MANGOPAY_URL                                    = data.aws_ssm_parameter.mangopay_url.value

    # Onfido
    ONFIDO_MOB_API_KEY        = data.aws_ssm_parameter.onfido_mob_api_key.value
    ONFIDO_MOB_APPLICATION_ID = data.aws_ssm_parameter.onfido_mob_application_id.value
    ONFIDO_WEB_API_KEY        = data.aws_ssm_parameter.onfido_web_api_key.value

    # Agreements
    PERSONAL_AGREEMENT_URL = data.aws_ssm_parameter.personal_agreement_url.value

    # Queues
    QUEUE_CONNECTION = data.aws_ssm_parameter.queue_connection.value
    QUEUE_DEFAULT    = data.aws_ssm_parameter.queue_default.value

    # Region
    region = data.aws_ssm_parameter.region_lower.value

    # Session
    SESSION_DRIVER        = data.aws_ssm_parameter.session_driver.value
    SESSION_SECURE_COOKIE = data.aws_ssm_parameter.session_secure_cookie.value

    # Telescope
    TELESCOPE_ENABLED = data.aws_ssm_parameter.telescope_enabled.value

    # Twilio
    TWILIO_ACCOUNT_SID = data.aws_ssm_parameter.twilio_account_sid.value
    TWILIO_AUTH_TOKEN  = data.aws_ssm_parameter.twilio_auth_token.value
  }
}