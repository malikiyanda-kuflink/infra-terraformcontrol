output "get_address_location_key" {
  value = module.secrets.GET_ADDRESS_LOCATION_KEY
  sensitive = true
}




output "app_env" {
  value = module.secrets.app_env
  sensitive = true

}

output "app_key" {
  value = module.secrets.app_key
  sensitive = true
}

output "app_url" {
  value = module.secrets.app_url
  sensitive = true

}

output "aws_access_key_id" {
  value = module.secrets.aws_access_key_id
  sensitive = true
}

output "aws_secret_access_key" {
  value = module.secrets.aws_secret_access_key
  sensitive = true
}

output "aws_default_region" {
  value = module.secrets.aws_default_region
    sensitive = true

}

output "aws_region" {
  value = module.secrets.aws_region
    sensitive = true

}

output "broadcast_driver" {
  value = module.secrets.broadcast_driver
    sensitive = true

}

output "cache_driver" {
  value = module.secrets.cache_driver
    sensitive = true

}

output "db_test_connection" {
  value = module.secrets.db_test_connection
    sensitive = true

}

output "db_test_port" {
  value = module.secrets.db_test_port
    sensitive = true

}

output "db_test_username" {
  value = module.secrets.db_test_username
  sensitive = true
}

output "db_test_password" {
  value = module.secrets.db_test_password
  sensitive = true
}

output "db_test_database" {
  value = module.secrets.db_test_database
    sensitive = true

}

output "db_test_host" {
  value = module.secrets.db_test_host
    sensitive = true

}

output "db_test_subnet_group_name" {
  value = module.secrets.db_test_subnet_group_name
    sensitive = true

}

# output "codepipeline_artifacts_bucket_name" {
#   value = module.secrets.codepipeline_artifacts_bucket_name
# }


output "app_log_level" {
  value = module.secrets.app_log_level
    sensitive = true

}

output "app_debug" {
  value = module.secrets.app_debug
    sensitive = true

}

output "activity_logger_enabled" {
  value = module.secrets.activity_logger_enabled
    sensitive = true

}

output "activity_logger_db_connection" {
  value = module.secrets.activity_logger_db_connection
    sensitive = true

}

output "docusign_account_id" {
  value = module.secrets.docusign_account_id
    sensitive = true

}

output "docusign_client_id" {
  value = module.secrets.docusign_client_id
    sensitive = true

}

output "docusign_client_secret" {
  value = module.secrets.docusign_client_secret
  sensitive = true
}

output "docusign_api_url" {
  value = module.secrets.docusign_api_url
    sensitive = true

}

output "docusign_base_url" {
  value = module.secrets.docusign_base_url
    sensitive = true

}

output "twilio_account_sid" {
  value = module.secrets.twilio_account_sid
    sensitive = true

}

output "twilio_auth_token" {
  value = module.secrets.twilio_auth_token
  sensitive = true
}

output "hubspot_access_token" {
  value = module.secrets.hubspot_access_token
  sensitive = true
}

output "mail_username" {
  value = module.secrets.mail_username
    sensitive = true

}

output "mandrill_apikey" {
  value = module.secrets.mandrill_apikey
  sensitive = true
}

output "ses_key" {
  value = module.secrets.ses_key
  sensitive = true
}

output "ses_secret" {
  value = module.secrets.ses_secret
  sensitive = true
}

output "ses_region" {
  value = module.secrets.ses_region
  sensitive = true

}

output "onfido_mob_api_key" {
  value = module.secrets.onfido_mob_api_key
  sensitive = true

}

output "onfido_mob_application_id" {
  value = module.secrets.onfido_mob_application_id
  sensitive = true

}






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
output "redis_elastic_cache_php_client" {
  value = module.secrets.redis_elastic_cache_php_client
  sensitive = true
}

output "redis_elastic_cache_port" {
  value = module.secrets.redis_elastic_cache_port
  sensitive = true
}


