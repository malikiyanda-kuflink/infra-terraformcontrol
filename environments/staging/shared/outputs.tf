output "onfido_web_api_key"               {
  value     = module.secrets.onfido_web_api_key
  sensitive = true
}

output "can_run_schedule" {
  value     = module.secrets.can_run_schedule
  sensitive = true
}

output "worker_can_run_schedule" {
  value     = module.secrets.worker_can_run_schedule
  sensitive = true
}

output "send_local_emails" {
  value     = module.secrets.send_local_emails
  sensitive = true
}

output "composer_home" {
  value     = module.secrets.composer_home
  sensitive = true
}

output "register_worker_routes" {
  value     = module.secrets.register_worker_routes
  sensitive = true
}

output "worker_register_worker_routes" {
  value     = module.secrets.worker_register_worker_routes
  sensitive = true
}

output "queue_connection" {
  value     = module.secrets.queue_connection
  sensitive = true
}

output "queue_default" {
  value     = module.secrets.queue_default
  sensitive = true
}

output "telescope_enabled" {
  value     = module.secrets.telescope_enabled
  sensitive = true
}

output "bank_of_england_api_key" {
  value     = module.secrets.bank_of_england_api_key
  sensitive = true
}

output "bank_of_england_api_url" {
  value     = module.secrets.bank_of_england_api_url
  sensitive = true
}

output "mangopay_client" {
  value     = module.secrets.mangopay_client
  sensitive = true
}

output "mangopay_passphrase" {
  value     = module.secrets.mangopay_passphrase
  sensitive = true
}

output "mangopay_url" {
  value     = module.secrets.mangopay_url
  sensitive = true
}

output "mangopay_redirect_url" {
  value     = module.secrets.mangopay_redirect_url
  sensitive = true
}

output "mangopay_topup_funds_limit_without_mangopay_aml" {
  value     = module.secrets.mangopay_topup_funds_limit_without_mangopay_aml
  sensitive = true
}

output "mangopay_max_funds_per_transaction_for_topup" {
  value     = module.secrets.mangopay_max_funds_per_transaction_for_topup
  sensitive = true
}

output "corporate_agreement_url" {
  value     = module.secrets.corporate_agreement_url
  sensitive = true
}

output "personal_agreement_url" {
  value     = module.secrets.personal_agreement_url
  sensitive = true
}

output "intercom_integration" {
  value     = module.secrets.intercom_integration
  sensitive = true
}

output "db_connection_audit_name" {
  value     = module.secrets.db_connection_audit_name
  sensitive = true
}

output "db_connection_read_only" {
  value     = module.secrets.db_connection_read_only
  sensitive = true
}

output "db_connection_staging_name" {
  value     = module.secrets.db_connection_staging_name
  sensitive = true
}

output "db_database_audit" {
  value     = module.secrets.db_database_audit
  sensitive = true
}

output "db_database_readonly" {
  value     = module.secrets.db_database_readonly
  sensitive = true
}

output "db_database_staging" {
  value     = module.secrets.db_database_staging
  sensitive = true
}

output "db_database_staging_testing" {
  value     = module.secrets.db_database_staging_testing
  sensitive = true
}

output "db_host_audit" {
  value     = module.secrets.db_host_audit
  sensitive = true
}

output "db_host_readonly" {
  value     = module.secrets.db_host_readonly
  sensitive = true
}

output "db_host_staging" {
  value     = module.secrets.db_host_staging
  sensitive = true
}

output "db_host_staging_testing" {
  value     = module.secrets.db_host_staging_testing
  sensitive = true
}

output "db_password_audit" {
  value     = module.secrets.db_password_audit
  sensitive = true
}

output "db_password_readonly" {
  value     = module.secrets.db_password_readonly
  sensitive = true
}

output "db_password_staging" {
  value     = module.secrets.db_password_staging
  sensitive = true
}

output "db_port_audit" {
  value     = module.secrets.db_port_audit
  sensitive = true
}

output "db_port_readonly" {
  value     = module.secrets.db_port_readonly
  sensitive = true
}

output "db_port_staging" {
  value     = module.secrets.db_port_staging
  sensitive = true
}

output "db_port_staging_testing" {
  value     = module.secrets.db_port_staging_testing
  sensitive = true
}

output "db_username_audit" {
  value     = module.secrets.db_username_audit
  sensitive = true
}

output "db_username_readonly" {
  value     = module.secrets.db_username_readonly
  sensitive = true
}

output "db_username_staging" {
  value     = module.secrets.db_username_staging
  sensitive = true
}

output "db_username_staging_testing" {
  value     = module.secrets.db_username_staging_testing
  sensitive = true
}

output "mail_driver" {
  value     = module.secrets.mail_driver
  sensitive = true
}

output "mail_host" {
  value     = module.secrets.mail_host
  sensitive = true
}

output "mail_port" {
  value     = module.secrets.mail_port
  sensitive = true
}


output "mail_encryption" {
  value     = module.secrets.mail_encryption
  sensitive = true
}



output "mail_password" {
  value     = module.secrets.mail_password
  sensitive = true
}

output "mandrill_secret" {
  value     = module.secrets.mandrill_secret
  sensitive = true
}

# Stripe
output "stripe_publishable_key" {
  value     = module.secrets.stripe_publishable_key
  sensitive = true
}

output "stripe_secret_key" {
  value     = module.secrets.stripe_secret_key
  sensitive = true
}

output "connected_stripe_account_id" {
  value     = module.secrets.connected_stripe_account_id
  sensitive = true
}

# Redis
output "redis_client" {
  value     = module.secrets.redis_client
  sensitive = true
}

output "redis_password" {
  value     = module.secrets.redis_password
  sensitive = true
}

output "redis_port" {
  value     = module.secrets.redis_port
  sensitive = true
}

# SQS
output "aws_sqs_driver" {
  value     = module.secrets.aws_sqs_driver
  sensitive = true
}

output "aws_sqs_prefix" {
  value     = module.secrets.aws_sqs_prefix
  sensitive = true
}

output "aws_sqs_queue" {
  value     = module.secrets.aws_sqs_queue
  sensitive = true
}

output "aws_sqs_queue_fifo" {
  value     = module.secrets.aws_sqs_queue_fifo
  sensitive = true
}

output "aws_sqs_region" {
  value     = module.secrets.aws_sqs_region
  sensitive = true
}

# Logging and session
output "log_channel" {
  value     = module.secrets.log_channel
  sensitive = true
}

output "session_driver" {
  value     = module.secrets.session_driver
  sensitive = true
}

output "session_secure_cookie" {
  value     = module.secrets.session_secure_cookie
  sensitive = true
}

output "redis_elastic_cache_password" {
  value = module.secrets.redis_elastic_cache_password
  sensitive = true
}
