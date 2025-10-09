############################################
# VARIABLES
############################################
# ---- Pipeline core ----
variable "pipeline_name" { type = string }
variable "codepipeline_role_arn" { type = string }
variable "pipeline_type" { type = string }
variable "execution_mode" { type = string }

# ---- Artifact store / S3 ----
variable "artifact_bucket_name" { type = string }
variable "artifact_store_type" { type = string }
variable "artifact_bucket_force_destroy" { type = bool }
variable "artifact_bucket_prevent_destroy" { type = bool }
variable "artifact_bucket_tags" { type = map(string) }
variable "enable_versioning" { type = bool }
variable "enable_bucket_cleanup_on_destroy" { type = bool }
variable "enable_pre_delete_cleanup" { type = bool }
variable "aws_cli_region" { type = string }

# ---- Source stage (CodeStar) ----
variable "source_stage_name" { type = string }
variable "source_action_name" { type = string }
variable "source_owner" { type = string }
variable "source_provider" { type = string }
variable "source_version" { type = string }
variable "source_output_artifact" { type = string }
variable "codestar_connection_arn" { type = string }
variable "full_repository_id" { type = string }
variable "branch_name" { type = string }

# ---- Deploy stage (Elastic Beanstalk) ----
variable "deploy_stage_name" { type = string }
variable "deploy_action_name_web" { type = string }
variable "deploy_action_name_worker" { type = string }
variable "deploy_owner" { type = string }
variable "deploy_provider" { type = string }
variable "deploy_version" { type = string }
variable "eb_application_name" { type = string }
variable "eb_web_environment_name" { type = string }
variable "enable_worker_deploy" { type = bool }
variable "eb_worker_environment_name" { type = string }

variable "codepipeline_role_name" { type = string }

variable "extras_policy_name" {
  type        = string
  description = "Name for the custom 'extras' policy"
  default     = "codepipeline-extras"
}
variable "passrole_arns" {
  type        = list(string)
  description = "Role ARNs CodePipeline must be able to PassRole (e.g., CodeBuild/EB roles). If empty, allows *."
  default     = []
}

variable "create_sns_topic" {
  type        = bool
  description = "Create the SNS topic & subscription for EB notifications"
  default     = true
}

variable "sns_topic_name" {
  type        = string
  description = "SNS topic name for EB notifications"
  default     = "eb-deployments"
}

variable "create_eb_topic" { type = bool }
variable "eb_topic_name" { type = string }
variable "eb_notification_protocol" { type = string }
variable "eb_notification_emails" { type = list(string) }

variable "create_pipeline_topic" { type = bool }
variable "pipeline_topic_name" { type = string }
variable "pipeline_notification_emails" { type = list(string) }

variable "create_pipeline_notification_rule" { type = bool }
variable "pipeline_notification_rule_name" { type = string }
variable "pipeline_arn" { type = string }
variable "pipeline_notification_event_type_ids" { type = list(string) }


# =============================================================================
# Core / Module
# =============================================================================
variable "application_name" { type = string }
variable "worker_env_name" { type = string }
variable "web_env_name" { type = string }
variable "application_description" { type = string }
variable "environment" { type = string }
variable "tier" { type = string } # e.g. "Worker" | "Web"
variable "solution_stack_name" { type = string }
variable "ec2_key_name" { type = string }
variable "web_instance_type" { type = string }
variable "worker_instance_type" { type = string }
variable "github_branch" { type = string }
variable "kuflink_codestar_connection" { type = string }
variable "tags" { type = map(string) }

variable "web_alb_arn" {
  type        = string
  description = "ARN of the Web ALB backing the EB environment (eu-west-2)."
}


# =============================================================================
# Access / IAM / Security Groups / SSH
# =============================================================================
variable "office_ip" { type = string }
variable "ssh_source_restriction" { type = string } # e.g. "tcp,22,22,1.2.3.4/32"
variable "eb_web_app_sg_id" { type = string }
variable "eb_role_arn" { type = string }
variable "eb_instance_profile_arn" { type = string }

# =============================================================================
# Networking
# =============================================================================
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }

# =============================================================================
# SSL / Load Balancer / Listener
# =============================================================================
variable "ssl_certificate_arn" { type = string }
variable "load_balancer_type" { type = string } # "application" | "classic" (ALB recommended)
variable "listener_enabled" { type = bool }     # enable default listener
variable "process_port" { type = number }       # e.g. 80
variable "listener_protocol" { type = string }  # e.g. "HTTPS"
variable "ssl_policy" { type = string }         # e.g. "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
variable "stickiness_enabled" { type = bool }   # ALB app stickiness on/off

# =============================================================================
# Notifications (SNS)
# =============================================================================
variable "notification_endpoint" { type = string } # email or HTTPS endpoint
variable "notification_protocol" { type = string } # "email", "https", etc.

# =============================================================================
# Logs & Monitoring
# =============================================================================
variable "stream_logs" { type = bool }
variable "log_retention_in_days" { type = number }
variable "log_publication_control" { type = bool }

# =============================================================================
# Deploy / Scaling / Env Type
# =============================================================================
variable "deployment_policy" { type = string }       # "AllAtOnce", "Rolling", "Immutable"
variable "worker_environment_type" { type = string } # "SingleInstance" | "LoadBalanced"
variable "asg_min_size" { type = number }
variable "asg_max_size" { type = number }

# --- AutoScaling trigger tuning (for CPU-based scaling) ---
variable "asg_measure_name" { type = string } # e.g. "CPUUtilization"
variable "asg_statistic" { type = string }    # e.g. "Average"
variable "asg_unit" { type = string }         # e.g. "Percent"
variable "asg_period" { type = number }       # seconds
variable "asg_evaluation_periods" { type = number }
variable "asg_breach_duration" { type = number } # seconds
variable "asg_upper_threshold" { type = number }
variable "asg_lower_threshold" { type = number }
variable "asg_upper_breach_scale_increment" { type = number }
variable "asg_lower_breach_scale_increment" { type = number }

# =============================================================================
# Worker (SQSD)
# =============================================================================
# variable "worker_queue_url"        { type = string } # SQS Queue URL for worker
variable "aws_sqs_queue_name" { type = string } # optional: expose name too
variable "sqsd_http_path" { type = string }     # e.g. "/worker/queue"
variable "sqsd_http_connections" { type = number }
variable "sqsd_visibility_timeout" { type = number }
variable "sqsd_max_retries" { type = number }
variable "sqsd_inactivity_timeout" { type = number }

# =============================================================================
# PHP / Proxy
# =============================================================================
variable "document_root" { type = string }          # e.g. "/public"
variable "php_max_execution_time" { type = string } # e.g. "600"
variable "php_memory_limit" { type = string }       # e.g. "2048M"
variable "proxy_server" { type = string }           # e.g. "nginx"

# =============================================================================
# Managed Platform Updates
# =============================================================================
variable "managed_actions_enabled" { type = bool }
variable "managed_update_level" { type = string }         # "minor" | "patch"
variable "managed_preferred_start_time" { type = string } # e.g. "Sat:04:00"

# =============================================================================
# Health Reporting
# =============================================================================
variable "health_config_document" { type = string } # JSON string for EB health rules

# =============================================================================
# Application Env (General)
# =============================================================================
variable "activity_logger_db_connection" { type = string }
variable "activity_logger_enabled" { type = string }
variable "app_debug" { type = string }
variable "app_env" { type = string }
variable "app_key" { type = string }
variable "app_log_level" { type = string }
variable "app_url" { type = string }

variable "aws_access_key_id" { type = string }
variable "aws_secret_access_key" { type = string }
variable "aws_region" { type = string }
variable "aws_default_region" { type = string }

variable "aws_sqs_driver" { type = string }
variable "aws_sqs_prefix" { type = string }
variable "aws_sqs_region" { type = string }

variable "bank_of_england_api_key" { type = string }
variable "bank_of_england_api_url" { type = string }
variable "broadcast_driver" { type = string }
variable "cache_driver" { type = string }
variable "can_run_schedule" { type = string }
variable "composer_home" { type = string }
variable "connected_stripe_account_id" { type = string }
variable "get_address_location_key" { type = string }
variable "hubspot_access_token" { type = string }
variable "intercom_integration" { type = string }
variable "log_channel" { type = string }

# --- Email ---
variable "mail_driver" { type = string }
variable "mail_encryption" { type = string }
variable "mail_host" { type = string }
variable "mail_password" { type = string }
variable "mail_port" { type = string }
variable "mail_username" { type = string }
variable "mandrill_apikey" { type = string }
variable "mandrill_secret" { type = string }
variable "send_local_emails" { type = string }
variable "ses_key" { type = string }
variable "ses_secret" { type = string }
variable "ses_region" { type = string }

# --- Stripe ---
variable "stripe_publishable_key" { type = string }
variable "stripe_secret_key" { type = string }

# --- Twilio ---
variable "twilio_account_sid" { type = string }
variable "twilio_auth_token" { type = string }

# --- DocuSign ---
variable "docusign_account_id" { type = string }
variable "docusign_api_url" { type = string }
variable "docusign_base_url" { type = string }
variable "docusign_client_id" { type = string }
variable "docusign_client_secret" { type = string }

# --- Onfido ---
variable "onfido_web_api_key" { type = string }
variable "onfido_mob_api_key" { type = string }
variable "onfido_mob_application_id" { type = string }

# --- Agreements ---
variable "personal_agreement_url" { type = string }
variable "corporate_agreement_url" { type = string }

# --- Queues (App) ---
variable "queue_connection" { type = string }
variable "queue_default" { type = string }
variable "register_worker_routes" { type = string }
variable "worker_register_worker_routes" { type = string }
variable "worker_can_run_schedule" { type = string }

# --- Sessions / Observability ---
variable "session_driver" { type = string }
variable "session_secure_cookie" { type = string }
variable "telescope_enabled" { type = string }

# --- Mangopay ---
variable "mangopay_client" { type = string }
variable "mangopay_max_funds_per_transaction_for_topup" { type = string }
variable "mangopay_passphrase" { type = string }
variable "mangopay_redirect_url" { type = string }
variable "mangopay_topup_funds_limit_without_mangopay_aml" { type = string }
variable "mangopay_url" { type = string }

# =============================================================================
# Database Env
# =============================================================================
variable "db_connection" { type = string }
variable "db_connection_readonly" { type = string }
variable "db_database" { type = string }
variable "db_host" { type = string }
variable "db_host_readonly" { type = string }
variable "db_password" { type = string }
variable "db_port" { type = string }
variable "db_username" { type = string }

# =============================================================================
# Redis – ElastiCache
# =============================================================================
# variable "redis_endpoint" { type = string }
# variable "redis_elastic_cache_password" { type = string }
# variable "redis_elastic_cache_php_client" { type = string }
# variable "redis_elastic_cache_port" { type = string }

# =============================================================================
# Redis – EC2 Instance
# =============================================================================
variable "redis_private_ip" { type = string }
variable "redis_port" { type = string }
variable "redis_client" { type = string }
variable "redis_password" { type = string }
