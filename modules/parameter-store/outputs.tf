# ---------------------------------------------------------------#
# Redshift Paramerters
# ---------------------------------------------------------------#
output "account_id" {
  value = data.aws_ssm_parameter.account_id.value
}

output "canonical_id" {
  value = data.aws_ssm_parameter.canonical_id.value
}

# ---------------------------------------------------------------#
# Redshift Paramerters
# ---------------------------------------------------------------#
output "redshift_password" {
  value = data.aws_ssm_parameter.redshift_password.value
}

output "redshift_username" {
  value = data.aws_ssm_parameter.redshift_username.value
}

output "redshift_database_name" {
  value = data.aws_ssm_parameter.redshift_database_name.value
}

output "redshift_port" {
  value = data.aws_ssm_parameter.redshift_port.value
}

# output "redshift_snapshot_identifier" {
#   value = data.aws_ssm_parameter.redshift_snapshot_identifier.value
# }
# ---------------------------------------------------------------#
# Metabase Paramerters
# ---------------------------------------------------------------#

output "metabase_ami" {
  value = data.aws_ssm_parameter.metabase_ami.value
}

output "metabase_instance_type" {
  value = data.aws_ssm_parameter.metabase_instance_type.value
}

# ---------------------------------------------------------------#
# output "ssh_key_parameter_name" {
#   value = data.aws_ssm_parameter.ssh_key_parameter_name
# }
output "ssh_key_parameter_name" {
  value = "kuflink/ssh/staging_pem"
}

output "brickfin_ssl_acm" {
  value = data.aws_ssm_parameter.brickfin_ssl_acm.value
}

# ---------------------------------------------------------------#
# Wordpress Paramerters
# ---------------------------------------------------------------#
output "TeamLeadPublicKey" {
  value = data.aws_ssm_parameter.TeamLeadPublicKey.value
}

output "DevOpsPublicKey" {
  value = data.aws_ssm_parameter.DevOpsPublicKey.value
}


output "DevOpsKeyPair" {
  value = data.aws_ssm_parameter.DevOpsKeyPair.value
}

output "StagingsKeyPair" {
  value = data.aws_ssm_parameter.StagingsKeyPair.value
}


output "DefaultAMI_ID" {
  value = data.aws_ssm_parameter.DefaultAMI_ID.value
}

output "DefaultInstanceType" {
  value = data.aws_ssm_parameter.DefaultInstanceType.value
}

output "office_ip" {
  value = data.aws_ssm_parameter.office_ip.value
}

output "ssl_cert" {
  value = data.aws_ssm_parameter.ssl_cert.value
}
# ---------------------------------------------------------------#
# Staging Paramerters

# ---------------------------------------------------------------#
output "staging_dms_role_arn" {
  value = data.aws_ssm_parameter.staging_dms_role_arn.value
}

output "staging_dms_endpoint_access_arn" {
  value = data.aws_ssm_parameter.staging_dms_endpoint_access_arn.value
}

output "staging_dms_logs_role_arn" {
  value = data.aws_ssm_parameter.staging_dms_logs_role_arn.value
}

# ---------------------------------------------------------------#
# Staging DB Paramerters
# ---------------------------------------------------------------#

# ---------------------------------------------------------------#
# Test DB Paramerters
# ---------------------------------------------------------------#
# output "db_test_snapshot_identifier" {
#   value = data.aws_ssm_parameter.db_test_snapshot_identifier.value
# }

# output "db_test_name_identifier" {
#   value = data.aws_ssm_parameter.db_test_name_identifier.value
# }

output "db_test_database" {
  value = data.aws_ssm_parameter.db_test_database.value
}

output "db_test_username" {
  value = data.aws_ssm_parameter.db_test_username.value
}

output "db_test_password" {
  value = data.aws_ssm_parameter.db_test_password.value
}

output "db_test_host" {
  value = data.aws_ssm_parameter.db_test_host.value
}

output "db_test_port" {
  value = data.aws_ssm_parameter.db_test_port.value
}

output "db_test_connection" {
  value = data.aws_ssm_parameter.db_test_connection.value
}

output "db_test_connection_readonly" {
  value = data.aws_ssm_parameter.db_test_connection_readonly.value
}

output "db_connection_read_only" {
  value = data.aws_ssm_parameter.db_connection_read_only.value
}

# ---------------------------------------------------------------#
# Unique to Test Environement
# ---------------------------------------------------------------#
output "app_key" {
  value = data.aws_ssm_parameter.app_key.value
}

output "twilio_account_sid" {
  value = data.aws_ssm_parameter.twilio_account_sid.value
}

output "twilio_auth_token" {
  value = data.aws_ssm_parameter.twilio_auth_token.value
}

output "GET_ADDRESS_LOCATION_KEY" {
  value = data.aws_ssm_parameter.GET_ADDRESS_LOCATION_KEY.value
}

# ---------------------------------------------------------------#
# Redis Elastic Cache 
# ---------------------------------------------------------------#
# output "redis_elastic_cache_cluster" {
#   value = data.aws_ssm_parameter.redis_elastic_cache_cluster.value
# }
output "redis_elastic_cache_php_client" {
  value = data.aws_ssm_parameter.redis_elastic_cache_php_client.value
}
output "redis_elastic_cache_password" {
  value = data.aws_ssm_parameter.redis_elastic_cache_password.value
}

output "new_redis_elastic_cache_password" {
  value = data.aws_ssm_parameter.new_redis_elastic_cache_password.value
}

output "redis_elastic_cache_port" {
  value = data.aws_ssm_parameter.redis_elastic_cache_port.value
}
# ---------------------------------------------------------------#
# Redis Instance Cache 
# ---------------------------------------------------------------#
output "redis_client" {
  value = data.aws_ssm_parameter.redis_client.value
}

# output "redis_host" {
#   value = data.aws_ssm_parameter.redis_host.value
# }

output "redis_password" {
  value = data.aws_ssm_parameter.redis_password.value
}
output "redis_port" {
  value = data.aws_ssm_parameter.redis_port.value
}

output "redis_test_client" {
  value = data.aws_ssm_parameter.redis_test_client.value
}

# output "redis_test_host" {
#   value = data.aws_ssm_parameter.redis_test_host.value
# }

output "redis_test_password" {
  value = data.aws_ssm_parameter.redis_test_password.value
}
output "redis_test_port" {
  value = data.aws_ssm_parameter.redis_test_port.value
}

# ---------------------------------------------------------------#


#Shared Variables
# ---------------------------------------------------------------#
output "kuflink_codestar_connection" {
  value = data.aws_ssm_parameter.kuflink_codestar_connection.value
}

output "frontend_codestar_connection" {
  value = data.aws_ssm_parameter.frontend_codestar_connection.value
}

output "admin_codestar_connection" {
  value = data.aws_ssm_parameter.admin_codestar_connection.value
}

output "aws_access_key_id" {
  value = data.aws_ssm_parameter.aws_access_key_id.value
}

output "aws_secret_access_key" {
  value = data.aws_ssm_parameter.aws_secret_access_key.value
}
output "app_env" {
  value = data.aws_ssm_parameter.app_env.value
}

output "db_host" {
  value = data.aws_ssm_parameter.db_host.value
}

output "db_port" {
  value = data.aws_ssm_parameter.db_port.value
}

output "db_database" {
  value = data.aws_ssm_parameter.db_database.value
}

output "db_password" {
  value = data.aws_ssm_parameter.db_password.value
}

output "db_connection" {
  value = data.aws_ssm_parameter.db_connection.value
}

output "db_username" {
  value = data.aws_ssm_parameter.db_username.value
}
output "mandrill_secret" {
  value = data.aws_ssm_parameter.mandrill_secret.value
}

output "mandrill_apikey" {
  value = data.aws_ssm_parameter.mandrill_apikey.value
}

output "activity_logger_db_connection" {
  value = data.aws_ssm_parameter.activity_logger_db_connection.value
}

output "activity_logger_enabled" {
  value = data.aws_ssm_parameter.activity_logger_enabled.value
}

output "app_debug" {
  value = data.aws_ssm_parameter.app_debug.value
}

output "app_log_level" {
  value = data.aws_ssm_parameter.app_log_level.value
}

output "app_url" {
  value = data.aws_ssm_parameter.app_url.value
}

output "aws_default_region" {
  value = data.aws_ssm_parameter.aws_default_region.value
}

output "aws_region" {
  value = data.aws_ssm_parameter.aws_region.value
}

output "aws_sqs_driver" {
  value = data.aws_ssm_parameter.aws_sqs_driver.value
}

output "aws_sqs_prefix" {
  value = data.aws_ssm_parameter.aws_sqs_prefix.value
}

output "aws_sqs_queue" {
  value = data.aws_ssm_parameter.aws_sqs_queue.value
}

output "aws_sqs_queue_fifo" {
  value = data.aws_ssm_parameter.aws_sqs_queue_fifo.value
}

output "aws_sqs_region" {
  value = data.aws_ssm_parameter.aws_sqs_region.value
}

output "bank_of_england_api_key" {
  value = data.aws_ssm_parameter.bank_of_england_api_key.value
}

output "bank_of_england_api_url" {
  value = data.aws_ssm_parameter.bank_of_england_api_url.value
}

output "broadcast_driver" {
  value = data.aws_ssm_parameter.broadcast_driver.value
}

output "cache_driver" {
  value = data.aws_ssm_parameter.cache_driver.value
}

output "can_run_schedule" {
  value = data.aws_ssm_parameter.can_run_schedule.value
}

output "worker_can_run_schedule" {
  value = data.aws_ssm_parameter.worker_can_run_schedule.value
}

output "composer_home" {
  value = data.aws_ssm_parameter.composer_home.value
}

output "connected_stripe_account_id" {
  value = data.aws_ssm_parameter.connected_stripe_account_id.value
}

output "corporate_agreement_url" {
  value = data.aws_ssm_parameter.corporate_agreement_url.value
}

output "docusign_account_id" {
  value = data.aws_ssm_parameter.docusign_account_id.value
}

output "docusign_api_url" {
  value = data.aws_ssm_parameter.docusign_api_url.value
}

output "docusign_base_url" {
  value = data.aws_ssm_parameter.docusign_base_url.value
}

output "docusign_client_id" {
  value = data.aws_ssm_parameter.docusign_client_id.value
}

output "docusign_client_secret" {
  value = data.aws_ssm_parameter.docusign_client_secret.value
}

output "hubspot_access_token" {
  value = data.aws_ssm_parameter.hubspot_access_token.value
}

output "intercom_integration" {
  value = data.aws_ssm_parameter.intercom_integration.value
}

output "log_channel" {
  value = data.aws_ssm_parameter.log_channel.value
}

output "mail_driver" {
  value = data.aws_ssm_parameter.mail_driver.value
}

output "mail_encryption" {
  value = data.aws_ssm_parameter.mail_encryption.value
}

output "mail_host" {
  value = data.aws_ssm_parameter.mail_host.value
}

output "mail_password" {
  value = data.aws_ssm_parameter.mail_password.value
}

output "mail_port" {
  value = data.aws_ssm_parameter.mail_port.value
}
output "mail_username" {
  value = data.aws_ssm_parameter.mail_username.value
}

output "mangopay_client" {
  value = data.aws_ssm_parameter.mangopay_client.value
}

output "mangopay_max_funds_per_transaction_for_topup" {
  value = data.aws_ssm_parameter.mangopay_max_funds_per_transaction_for_topup.value
}

output "mangopay_passphrase" {
  value = data.aws_ssm_parameter.mangopay_passphrase.value
}

output "mangopay_redirect_url" {
  value = data.aws_ssm_parameter.mangopay_redirect_url.value
}

output "mangopay_topup_funds_limit_without_mangopay_aml" {
  value = data.aws_ssm_parameter.mangopay_topup_funds_limit_without_mangopay_aml.value
}

output "mangopay_url" {
  value = data.aws_ssm_parameter.mangopay_url.value
}

output "onfido_mob_api_key" {
  value = data.aws_ssm_parameter.onfido_mob_api_key.value
}

output "personal_agreement_url" {
  value = data.aws_ssm_parameter.personal_agreement_url.value
}

output "onfido_mob_application_id" {
  value = data.aws_ssm_parameter.onfido_mob_application_id.value
}

output "onfido_web_api_key" {
  value = data.aws_ssm_parameter.onfido_web_api_key.value
}

output "queue_connection" {
  value = data.aws_ssm_parameter.queue_connection.value
}

output "queue_default" {
  value = data.aws_ssm_parameter.queue_default.value
}

output "register_worker_routes" {
  value = data.aws_ssm_parameter.register_worker_routes.value
}

output "worker_register_worker_routes" {
  value = data.aws_ssm_parameter.worker_register_worker_routes.value
}

output "send_local_emails" {
  value = data.aws_ssm_parameter.send_local_emails.value
}

output "ses_key" {
  value = data.aws_ssm_parameter.ses_key.value
}

output "ses_region" {
  value = data.aws_ssm_parameter.ses_region.value
}

output "ses_secret" {
  value = data.aws_ssm_parameter.ses_secret.value
}

output "session_driver" {
  value = data.aws_ssm_parameter.session_driver.value
}

output "session_secure_cookie" {
  value = data.aws_ssm_parameter.session_secure_cookie.value
}

output "stripe_publishable_key" {
  value = data.aws_ssm_parameter.stripe_publishable_key.value
}

output "stripe_secret_key" {
  value = data.aws_ssm_parameter.stripe_secret_key.value
}

output "telescope_enabled" {
  value = data.aws_ssm_parameter.telescope_enabled.value
}

##-----------------------------------------------------------------------------##
