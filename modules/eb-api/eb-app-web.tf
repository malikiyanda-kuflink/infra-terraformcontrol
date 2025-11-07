# =================================================================================================
# Elastic Beanstalk: Kuflink-${var.environment} (Laravel 9, AL2023 PHP 8.4)
# =================================================================================================

# ---------------------------------------------------------------#
# Elastic Beanstalk Application
# ---------------------------------------------------------------#
resource "aws_elastic_beanstalk_application" "kuflink_app" {
  name        = var.application_name
  description = var.application_description
  tags        = var.tags

}

# ---------------------------------------------------------------#
# Elastic Beanstalk Environment (Web)
# ---------------------------------------------------------------#
resource "aws_elastic_beanstalk_environment" "web_env" {
  name                = var.web_env_name
  application         = var.application_name
  solution_stack_name = var.solution_stack_name
  tags                = var.tags

  # lifecycle {
  #   ignore_changes = [setting] # TEMPORARY; remove once stable
  # }

  # -------------------------------------------
  # Load Balancer / HTTPS / Listeners
  # -------------------------------------------
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "AccessLogsS3Enabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "AccessLogsS3Bucket"
    value     = aws_s3_bucket.alb_logs.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ALB_CONN_LOG_BUCKET"
    value     = var.alb_log_bucket
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENABLE_CONN_LOGS"
    value     = "true"
  }

  # Optional: per-env prefix
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ALB_CONN_LOG_PREFIX"
    value     = var.alb_conn_log_prefix # e.g. "conn"
  }
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "AccessLogsS3Prefix"
    value     = "alb" # optional
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = var.ssl_certificate_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = var.load_balancer_type
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.public_subnet_ids)
  }

  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = var.listener_enabled
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = var.process_port
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = var.listener_protocol
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLPolicy"
    value     = var.ssl_policy
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessEnabled"
    value     = var.stickiness_enabled
  }

  # -------------------------------------------
  # Notifications (SNS)
  # -------------------------------------------
  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Endpoint"
    value     = var.notification_endpoint
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Protocol"
    value     = var.notification_protocol
  }

  # -------------------------------------------
  # Logs & Monitoring
  # -------------------------------------------
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = var.stream_logs
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = var.log_retention_in_days
  }

  setting {
    namespace = "aws:elasticbeanstalk:hostmanager"
    name      = "LogPublicationControl"
    value     = var.log_publication_control
  }

  # -------------------------------------------
  # Service Access (keys, SGs, roles, deployment policy)
  # -------------------------------------------
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = var.deployment_policy
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.ec2_key_name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.eb_web_app_sg_id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SSHSourceRestriction"
    value     = var.ssh_source_restriction
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = var.eb_instance_profile_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = var.eb_role_arn
  }

  # -------------------------------------------
  # Networking (VPC & Subnets)
  # -------------------------------------------
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.private_subnet_ids)
  }

  # -------------------------------------------
  # Instance & Scaling (ASG, instance type, triggers)
  # -------------------------------------------
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.asg_max_size
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.asg_min_size
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.web_instance_type
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = var.asg_measure_name
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = var.asg_statistic
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = var.asg_unit
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Period"
    value     = var.asg_period
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "EvaluationPeriods"
    value     = var.asg_evaluation_periods
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "BreachDuration"
    value     = var.asg_breach_duration
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = var.asg_upper_threshold
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = var.asg_lower_threshold
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperBreachScaleIncrement"
    value     = var.asg_upper_breach_scale_increment
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerBreachScaleIncrement"
    value     = var.asg_lower_breach_scale_increment
  }

  # -------------------------------------------
  # Proxy & PHP settings
  # -------------------------------------------
  setting {
    namespace = "aws:elasticbeanstalk:environment:proxy"
    name      = "ProxyServer"
    value     = var.proxy_server
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "document_root"
    value     = var.document_root
  }

  # setting {
  #   namespace = "aws:elasticbeanstalk:container:php:phpini"
  #   name      = "max_execution_time"
  #   value     = var.php_max_execution_time
  # }

  # setting {
  #   namespace = "aws:elasticbeanstalk:container:php:phpini"
  #   name      = "memory_limit"
  #   value     = var.php_memory_limit
  # }

  # -------------------------------------------
  # Managed Platform Updates
  # -------------------------------------------
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = var.managed_actions_enabled
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = var.managed_update_level
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = var.managed_preferred_start_time
  }

  # -------------------------------------------
  # Health Reporting (JSON)
  # -------------------------------------------
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "ConfigDocument"
    value     = var.health_config_document
  }

  # ================================================================================================
  # ENVIRONMENT VARIABLES (aws:elasticbeanstalk:application:environment)
  # ================================================================================================

  # Active environment variables
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "APP_ENV"
    value     = var.app_env
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "APP_KEY"
    value     = var.app_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "region"
    value     = var.aws_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = var.aws_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DEFAULT_REGION"
    value     = var.aws_default_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_ACCESS_KEY_ID"
    value     = var.aws_access_key_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_SECRET_ACCESS_KEY"
    value     = var.aws_secret_access_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_SQS_DRIVER"
    value     = var.aws_sqs_driver
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_SQS_PREFIX"
    value     = var.aws_sqs_prefix
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_SQS_QUEUE"
    value     = aws_sqs_queue.worker_queue.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "COMPOSER_HOME"
    value     = var.composer_home
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MANDRILL_APIKEY"
    value     = var.mandrill_apikey
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MANDRILL_SECRET"
    value     = var.mandrill_secret
  }

  # ================================================================================================
  # Redis EC2 Instance
  # ================================================================================================
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_HOST"
    value     = var.redis_private_ip
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_PORT"
    value     = var.redis_port
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_CLIENT"
    value     = var.redis_client
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_PASSWORD"
    value     = var.redis_password
  }

  # ================================================================================================
  # Database Parameters 
  # ================================================================================================
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_CONNECTION"
    value     = var.db_connection
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_CONNECTION_READONLY"
    value     = var.db_connection_readonly
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_DATABASE"
    value     = var.db_database
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST"
    value     = var.db_host
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST_READONLY"
    value     = var.db_host_readonly
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASSWORD"
    value     = var.db_password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PORT"
    value     = var.db_port
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USERNAME"
    value     = var.db_username
  }

  # ================================================================================================
  # Additional environment variables 
  # ================================================================================================
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ACTIVITY_LOGGER_DB_CONNECTION"
    value     = var.activity_logger_db_connection
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ACTIVITY_LOGGER_ENABLED"
    value     = var.activity_logger_enabled
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "APP_DEBUG"
    value     = var.app_debug
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "APP_LOG_LEVEL"
    value     = var.app_log_level
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "APP_URL"
    value     = var.app_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_SQS_REGION"
    value     = var.aws_sqs_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "BANK_OF_ENGLAND_API_KEY"
    value     = var.bank_of_england_api_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "BANK_OF_ENGLAND_API_URL"
    value     = var.bank_of_england_api_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "BROADCAST_DRIVER"
    value     = var.broadcast_driver
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "CACHE_DRIVER"
    value     = var.cache_driver
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "CAN_RUN_SCHEDULE"
    value     = var.can_run_schedule
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "CONNECTED_STRIPE_ACCOUNT_ID"
    value     = var.connected_stripe_account_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "CORPORATE_AGREEMENT_URL"
    value     = var.corporate_agreement_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCUSIGN_ACCOUNT_ID"
    value     = var.docusign_account_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCUSIGN_API_URL"
    value     = var.docusign_api_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCUSIGN_BASE_URL"
    value     = var.docusign_base_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCUSIGN_CLIENT_ID"
    value     = var.docusign_client_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCUSIGN_CLIENT_SECRET"
    value     = var.docusign_client_secret
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "HUBSPOT_ACCESS_TOKEN"
    value     = var.hubspot_access_token
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "INTERCOM_INTEGRATION"
    value     = var.intercom_integration
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "LOG_CHANNEL"
    value     = var.log_channel
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MAIL_DRIVER"
    value     = var.mail_driver
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MAIL_PORT"
    value     = var.mail_port
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MANGOPAY_CLIENT"
    value     = var.mangopay_client
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MANGOPAY_MAX_FUNDS_PER_TRANSACTION_FOR_TOPUP"
    value     = var.mangopay_max_funds_per_transaction_for_topup
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MANGOPAY_PASSPHRASE"
    value     = var.mangopay_passphrase
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MANGOPAY_REDIRECT_URL"
    value     = var.mangopay_redirect_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MANGOPAY_TOPUP_FUNDS_LIMIT_WITHOUT_MANGOPAY_AML"
    value     = var.mangopay_topup_funds_limit_without_mangopay_aml
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MANGOPAY_URL"
    value     = var.mangopay_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ONFIDO_MOB_API_KEY"
    value     = var.onfido_mob_api_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ONFIDO_MOB_APPLICATION_ID"
    value     = var.onfido_mob_application_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ONFIDO_WEB_API_KEY"
    value     = var.onfido_web_api_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PERSONAL_AGREEMENT_URL"
    value     = var.personal_agreement_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "QUEUE_CONNECTION"
    value     = var.queue_connection
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "QUEUE_DEFAULT"
    value     = var.queue_default
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REGISTER_WORKER_ROUTES"
    value     = var.register_worker_routes
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SEND_LOCAL_EMAILS"
    value     = var.send_local_emails
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SES_KEY"
    value     = var.ses_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SES_REGION"
    value     = var.ses_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SES_SECRET"
    value     = var.ses_secret
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SESSION_DRIVER"
    value     = var.session_driver
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SESSION_SECURE_COOKIE"
    value     = var.session_secure_cookie
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "STRIPE_PUBLISHABLE_KEY"
    value     = var.stripe_publishable_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "STRIPE_SECRET_KEY"
    value     = var.stripe_secret_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "TELESCOPE_ENABLED"
    value     = var.telescope_enabled
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "TWILIO_ACCOUNT_SID"
    value     = var.twilio_account_sid
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "TWILIO_AUTH_TOKEN"
    value     = var.twilio_auth_token
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "GET_ADDRESS_LOCATION_KEY"
    value     = var.get_address_location_key
  }
}
