variable "kuflink_codestar_connection" {
  type = string
}

variable "github_branch" {
  description = "The GitHub branch name"
  type        = string
  default = "main"
}

variable "worker_register_worker_routes" {
  type        = string
  description = "Register worker routes for worker"
}

variable "worker_can_run_schedule" {
  type        = string
  description = "Enable or disable schedule runs"
}

variable "db_connection_read_only" {
  type        = string
  description = "Read-only database connection"
}

variable "eb_role_arn" {
  type = string
}

variable "eb_instance_profile_arn" {
  description = "Name for the Elasticbeanstalk Instance Profile"
  type        = string
}

variable "ssl_certificate_arn" {
  type        = string
  description = "ACM ARN for HTTPS listener"
}


variable "redis_elastic_cache_password" {
  description = "Auth token for Redis (must be 16–128 chars)"
  type        = string
}

variable "redis_endpoint" {
  description = "Redis Endpoint"
  type        = string
}

variable "redis_elastic_cache_php_client" {
  description = "Redis Client"
  type        = string
}


variable "redis_elastic_cache_port" {
  description = "Redis Port"
  type        = string
}






# Networking
variable "vpc_id" {
  type        = string
  description = "VPC ID for the application"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs"
}

# variable "elb_security_group_id" {
#   type        = string
#   description = "Security group ID for ELB"
# }

# variable "eb_ssh_sg_id" {
#   type        = string
#   description = "Security group ID for EB SSH access"
# }

# variable "ssl_certificate_arn" {
#   type        = string
#   description = "SSL Certificate ARN"
# }

# Secrets
# variable "db_test_username" {
#   type        = string
#   description = "Database username for test DB"
# }

# variable "db_test_password" {
#   type        = string
#   description = "Database password for test DB"
# }

# variable "db_test_host" {
#   type        = string
#   description = "Database host for test DB"
# }

# variable "redis_elastic_cache_password" {
#   type        = string
#   description = "Redis password for Elastic Cache"
# }

variable "mandrill_secret" {
  type        = string
  description = "Mandrill secret key"
}

variable "bank_of_england_api_url" {
  type        = string
  description = "Bank of England API URL"
}

# variable "app_key" {
#   type        = string
#   description = "Laravel application key"
# }

# App configuration


# variable "app_url" {
#   type        = string
#   description = "Application base URL"
# }

variable "environment" {
  type        = string
  description = "Deployment environment name"
}

variable "get_address_location_key" {
  type = string
}

variable "twilio_account_sid" {
  type = string
}

variable "twilio_auth_token" {
  type = string
}

# variable "codepipeline_artifacts_bucket_name" {
#   type = string
# }



# variable "backend_terraform_health_topic_arn" {
#   type = string
# }

data "aws_cloudwatch_log_group" "waf_log_group" {
  name = aws_cloudwatch_log_group.waf_log_group.name
}

variable "waf_acl_name" {
  description = "The name of the existing WAF WebACL"
  type        = string
  default     = "test-kuflink-dev-laravel-api-waf"
}

##-------------------------------------ENV VARIABLES--------------------------------------------------##
##-------------------------------------ENV VARIABLES--------------------------------------------------##
variable "activity_logger_db_connection" {
  type        = string
  description = "Database connection for activity logger"
}

variable "activity_logger_enabled" {
  type        = string
  description = "Enable or disable activity logger"
}

variable "app_debug" {
  type        = string
  description = "Enable or disable application debug mode"
}

variable "app_env" {
  type        = string
  description = "Environment for the application"
}

variable "app_key" {
  type        = string
  description = "Application key"
}

variable "app_log_level" {
  type        = string
  description = "Log level for the application"
}

variable "app_url" {
  type        = string
  description = "Application URL"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
}

variable "aws_default_region" {
  type        = string
  description = "Default AWS region"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
}

variable "aws_sqs_driver" {
  type        = string
  description = "SQS driver"
}

variable "aws_sqs_prefix" {
  type        = string
  description = "SQS prefix"
}

# variable "aws_sqs_queue_fifo" {
#   type        = string
#   description = "SQS FIFO queue name"
# }

variable "aws_sqs_region" {
  type        = string
  description = "AWS region for SQS"
}

variable "bank_of_england_api_key" {
  type        = string
  description = "API key for Bank of England"
}

variable "broadcast_driver" {
  type        = string
  description = "Broadcast driver"
}

variable "cache_driver" {
  type        = string
  description = "Cache driver"
}

variable "can_run_schedule" {
  type        = string
  description = "Enable or disable schedule runs"
}

variable "composer_home" {
  type        = string
  description = "Composer home directory"
}

variable "connected_stripe_account_id" {
  type = string
}

variable "corporate_agreement_url" {
  type = string
}

##--------------------------------- DB ENV VARIABLES-------------------------------##

variable "db_test_subnet_group_name" {
  type        = string
  description = "Subnet group name for the database"
}

variable "db_test_host" {
  type        = string
  description = "Database host"
}

variable "db_test_port" {
  type        = string
  description = "Database port"
}

variable "db_test_database" {
  type        = string
  description = "Database name"
}

variable "db_test_password" {
  type        = string
  description = "Database password"
}

variable "db_test_connection" {
  type        = string
  description = "Database connection string"
}

variable "db_test_username" {
  type        = string
  description = "Database username"
}
##--------------------------------- DB ENV VARIABLES-------------------------------##

variable "db_connection_audit_name" {
  type        = string
  description = "Audit database connection name"
}

variable "db_connection_staging_name" {
  type        = string
  description = "Staging database connection name"
}

variable "db_database_audit" {
  type        = string
  description = "Audit database name"
}

variable "db_database_readonly" {
  type        = string
  description = "Read-only database name"
}

variable "db_database_staging" {
  type        = string
  description = "Staging database name"
}

variable "db_database_staging_testing" {
  type = string
}

variable "db_host_audit" {
  type        = string
  description = "Audit database host"
}

variable "db_host_readonly" {
  type        = string
  description = "Read-only database host"
}

variable "db_host_staging" {
  type        = string
  description = "Staging database host"
}

variable "db_host_staging_testing" {
  type = string
}

variable "db_password_audit" {
  type        = string
  description = "Audit database password"
}

variable "db_password_readonly" {
  type        = string
  description = "Read-only database password"
}

variable "db_password_staging" {
  type        = string
  description = "Staging database password"
}

variable "db_port_audit" {
  type        = string
  description = "Audit database port"
}

variable "db_port_readonly" {
  type        = string
  description = "Read-only database port"
}

variable "db_port_staging" {
  type        = string
  description = "Staging database port"
}

variable "db_port_staging_testing" {
  type = string
}

variable "db_username_audit" {
  type        = string
  description = "Audit database username"
}

variable "db_username_readonly" {
  type        = string
  description = "Read-only database username"
}

variable "db_username_staging" {
  type        = string
  description = "Staging database username"
}

variable "db_username_staging_testing" {
  type = string
}

variable "docusign_account_id" {
  type        = string
  description = "DocuSign account ID"
}

variable "docusign_api_url" {
  type        = string
  description = "DocuSign API URL"
}

variable "docusign_base_url" {
  type        = string
  description = "DocuSign base URL"
}

variable "docusign_client_id" {
  type        = string
  description = "DocuSign client ID"
}

variable "docusign_client_secret" {
  type        = string
  description = "DocuSign client secret"
}

variable "hubspot_access_token" {
  type        = string
  description = "HubSpot access token"
}

variable "intercom_integration" {
  type        = string
  description = "Intercom integration key"
}

variable "log_channel" {
  type        = string
  description = "Log channel"
}

variable "mail_driver" {
  type        = string
  description = "Mail driver"
}

variable "mail_encryption" {
  type = string
}

variable "mail_host" {
  type = string
}

variable "mail_password" {
  type = string
}

variable "mail_port" {
  type        = string
  description = "Mail port"
}

variable "mail_username" {
  type = string
}

variable "mandrill_apikey" {
  type        = string
  description = "Mandrill API secret"
}

variable "mangopay_client" {
  type        = string
  description = "Mangopay client"
}

variable "mangopay_max_funds_per_transaction_for_topup" {
  type        = string
  description = "Max funds per transaction for Mangopay top-up"
}

variable "mangopay_passphrase" {
  type        = string
  description = "Mangopay passphrase"
}

variable "mangopay_redirect_url" {
  type        = string
  description = "Mangopay redirect URL"
}

variable "mangopay_topup_funds_limit_without_mangopay_aml" {
  type        = string
  description = "Top-up funds limit without Mangopay AML"
}

variable "mangopay_url" {
  type        = string
  description = "Mangopay URL"
}

variable "onfido_mob_api_key" {
  type        = string
  description = "Onfido API key"
}

variable "onfido_mob_application_id" {
  type        = string
  description = "Onfido mobile application ID"
}

variable "onfido_web_api_key" {
  type        = string
  description = "Onfido web API key"
}

variable "personal_agreement_url" {
  type = string
}

variable "queue_connection" {
  type        = string
  description = "Queue connection"
}

variable "queue_default" {
  type        = string
  description = "Default queue name"
}

# Redis Elastic Cache 
# ---------------------------------------------------------------#
# variable "redis_elastic_cache_primary_endpoint" {
#   type        = string
#   description = "Hostname or IP address for Redis Elastic Cache"
# }
# variable "redis_eleastic_cache_cluster_id" {
#     type        = string
#   description = "Cluster ID for Redis Elastic Cache"
# }

variable "register_worker_routes" {
  type        = string
  description = "Register worker routes for worker"
}

variable "send_local_emails" {
  type        = string
  description = "Enable or disable sending local emails"
}

variable "ses_key" {
  type        = string
  description = "SES key"
}

variable "ses_region" {
  type        = string
  description = "SES region"
}

variable "ses_secret" {
  type        = string
  description = "SES secret"
}

variable "session_driver" {
  type        = string
  description = "Session driver"
}

variable "session_secure_cookie" {
  type = string
}

variable "stripe_publishable_key" {
  type        = string
  description = "Stripe publishable key"
}

variable "stripe_secret_key" {
  type        = string
  description = "Stripe secret key"
}

variable "telescope_enabled" {
  type = string
}
##-------------------------------------ENV VARIABLES--------------------------------------------------##
##-------------------------------------ENV VARIABLES--------------------------------------------------##