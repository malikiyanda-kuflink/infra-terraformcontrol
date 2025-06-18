resource "aws_elastic_beanstalk_application" "kuflink_app" {
  name        = "Kuflink-Test"
  description = "Test Kuflink Laravel 9 Application"
}

resource "aws_elastic_beanstalk_environment" "kuflink_env" {
  name                = "Kuflink-Test-Web"
  application         = aws_elastic_beanstalk_application.kuflink_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.6.2 running PHP 8.4"

  tags = {
      Descriptpion = "ElasticBeanstalk Web Application"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = var.ssl_certificate_arn
  }

    # Redis Elastic Cache 
# ---------------------------------------------------------------#
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_HOST"
    value     = "tls://${var.redis_endpoint}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_CLIENT"
    value     = var.redis_elastic_cache_php_client 
    # value     = var.redis_client

  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_PASSWORD"
    value     = var.redis_elastic_cache_password
    # value     = var.redis_password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_PORT"
    value     = var.redis_elastic_cache_port
  }





  # setting {
  #   namespace = "aws:ec2:metadata"
  #   name      = "InstanceMetadataTags"
  #   value     = "enabled"
  # }
  
  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Endpoint"
    value     = "m.iyanda@kuflink.com"
  }
  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Protocol"
    value     = "email"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    # value     = "Immutable"
    value     = "AllAtOnce"
  }

    # Enable Log Streaming
  setting {
    namespace  = "aws:elasticbeanstalk:cloudwatch:logs"
    name = "StreamLogs"
    value       = "true"
  }


  # Specify how many days to keep logs in CloudWatch
  setting {
    namespace  = "aws:elasticbeanstalk:cloudwatch:logs"
    name        = "RetentionInDays"
    value       = "30"
  }

# setting {
#   namespace = "aws:elasticbeanstalk:s3"
#   name      = "RotateLogs"
#   value     = "true"
# }


  # Ensure the EB Host Manager publishes logs
  setting {
    namespace  = "aws:elasticbeanstalk:hostmanager"
    name =     "LogPublicationControl"
    value       = "true"
  }
   
  # ------Service Access
  # NOTE:Change manually for security risks EB auto creating 
  # sg with ssh access from (0.0.0.0/0) with EC2KeyName option setting
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    # value     = "Malik_kuflink"
    value     = "staging" 
  }

  # This ensures EB uses only *your* SG, so it won't create or inject its own rules
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.elb_security_group.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SSHSourceRestriction"
    value     = "tcp,22,22,35.176.203.87/32"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = var.eb_instance_profile_arn
  }

  # Assign the Service Role
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = var.eb_role_arn
  }


  # ------Service Access
  # ------Networking and Databases
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

  # ------Networking and Databases
  # ------Instance traffic and scaling 

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  # setting {
  #   namespace = "aws:elbv2:loadbalancer"
  #   name      = "SecurityGroups"
  #   value     = var.elb_security_group_id
  # }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.public_subnet_ids)
  }

  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "80"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLPolicy"
    value     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  }

  # Disable ALB sticky sessions (session stickiness)
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessEnabled"
    value     = "false"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "3"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  # setting {
  #   namespace = "aws:autoscaling:launchconfiguration"
  #   name      = "ImageId"
  #   # value     = "ami-015cbfa44225fa485" #8.2
  #   # value     = "ami-066fcdb72b9631a84" #8.3
  # }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.medium"
    # value     = "t3.xlarge"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "CPUUtilization"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = "Average"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "Percent"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Period"
    value     = "5"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "EvaluationPeriods"
    value     = "2"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "BreachDuration"
    value     = "20"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = "95"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = "10"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperBreachScaleIncrement"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerBreachScaleIncrement"
    value     = "-1"
  }



  # ------Instance traffic and scaling 
  # ------Updates, monitoring, and logging 
  # setting {
  #   namespace = "aws:elasticbeanstalk:environment:monitoring"
  #   name      = "LowerThreshold"
  #   value     = "500000"
  # }

  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "document_root"
    value     = "/public"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:proxy"
    name      = "ProxyServer"
    value     = "nginx"
  }

  # Enable Managed Platform Updates
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = "minor" # or "patch" for only patch updates
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = "Sat:04:00" # Schedule updates at a preferred time
  }

  # Update max_execution_time
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "max_execution_time"
    value     = "600"
  }

  # Update memory_limit
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "memory_limit"
    value     = "2048M"
  }

setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "ConfigDocument"
    value     = <<JSON
{
  "Version": 1,
  "Rules": {
    "Environment": {
      "Application": {
        "ApplicationRequests4xx": {
          "Enabled": false
        }
      }
    }
  }
}
JSON
}



  #-------Environment properties
  ##-------------------------------------EB OPTION SETTINGS--------------------------------------------------##

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
    name      = "AWS_ACCESS_KEY_ID"
    value     = var.aws_access_key_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DEFAULT_REGION"
    value     = var.aws_default_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = var.aws_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "region"
    value     = var.aws_region
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

  # setting {
  #   namespace = "aws:elasticbeanstalk:application:environment"
  #   name      = "AWS_SQS_QUEUE_FIFO"
  #   value     = var.aws_sqs_queue_fifo
  # }

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
    name      = "COMPOSER_HOME"
    value     = var.composer_home
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
    name      = "DB_CONNECTION"
    value     = var.db_test_connection
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_CONNECTION_AUDIT_NAME"
    value     = var.db_connection_audit_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_CONNECTION_STAGING_NAME"
    value     = var.db_connection_staging_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_DATABASE"
    value     = var.db_test_database
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_DATABASE_AUDIT"
    value     = var.db_database_audit
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_DATABASE_READONLY"
    value     = var.db_database_readonly
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_DATABASE_STAGING"
    value     = var.db_database_staging
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_DATABASE_STAGING_TESTING"
    value     = var.db_database_staging_testing
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST"
    value     = var.db_test_host
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST_AUDIT"
    value     = var.db_host_audit
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST_READONLY"
    value     = var.db_host_readonly
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST_STAGING"
    value     = var.db_host_staging
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST_STAGING_TESTING"
    value     = var.db_host_staging_testing
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASSWORD"
    value     = var.db_test_password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASSWORD_AUDIT"
    value     = var.db_password_audit
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASSWORD_READONLY"
    value     = var.db_password_readonly
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASSWORD_STAGING"
    value     = var.db_password_staging
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PORT"
    value     = var.db_test_port
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PORT_AUDIT"
    value     = var.db_port_audit
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PORT_READONLY"
    value     = var.db_port_readonly
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PORT_STAGING"
    value     = var.db_port_staging
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PORT_STAGING_TESTING"
    value     = var.db_port_staging_testing
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USERNAME"
    value     = var.db_test_username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USERNAME_AUDIT"
    value     = var.db_username_audit
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USERNAME_READONLY"
    value     = var.db_username_readonly
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USERNAME_STAGING"
    value     = var.db_username_staging
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USERNAME_STAGING_TESTING"
    value     = var.db_username_staging_testing
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
    name      = "MANDRILL_APIKEY"
    value     = var.mandrill_apikey
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MANDRILL_SECRET"
    value     = var.mandrill_secret
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
  # ---------------------------------------------------------------#

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
    name = "TWILIO_ACCOUNT_SID"
    value = var.twilio_account_sid
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "TWILIO_AUTH_TOKEN"
    value = var.twilio_auth_token 
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "GET_ADDRESS_LOCATION_KEY"
    value = var.get_address_location_key   
  }
}
