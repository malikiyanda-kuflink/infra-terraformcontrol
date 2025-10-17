resource "aws_wafv2_web_acl_association" "eb_alb" {
  count = local.enable_eb && local.enable_eb_waf ? 1 : 0

  # Direct reference to module output
  resource_arn = module.eb-api[0].load_balancer_arn
  web_acl_arn  = module.eb_waf[0].web_acl_arn

  # Terraform automatically handles dependencies through the reference
  depends_on = [
    module.eb-api,
    module.eb_waf
  ]
}

module "eb-api" {
  count  = local.enable_eb ? 1 : 0
  source = "../../../modules/eb-api"

  codepipeline_role_name = local.codepipeline_role_name
  # --- EB & Pipeline notifications (pass-through to module) ---
  create_eb_topic          = local.create_eb_topic
  eb_topic_name            = local.eb_topic_name
  eb_notification_protocol = local.eb_notification_protocol
  eb_notification_emails   = local.eb_notification_emails

  create_pipeline_topic        = local.create_pipeline_topic
  pipeline_topic_name          = local.pipeline_topic_name
  pipeline_notification_emails = local.pipeline_notification_emails

  create_pipeline_notification_rule    = local.create_pipeline_notification_rule
  pipeline_notification_rule_name      = local.pipeline_notification_rule_name
  pipeline_arn                         = local.pipeline_arn
  pipeline_notification_event_type_ids = local.pipeline_notification_event_type_ids

  # Core
  application_name        = local.name_prefix_upper
  application_description = local.application_description
  environment             = local.environment
  tier                    = local.tier
  solution_stack_name     = local.solution_stack_name
  ec2_key_name            = local.ec2_key_name
  web_instance_type       = local.web_instance_type
  worker_instance_type    = local.worker_instance_type
  github_branch           = local.github_branch

  # Env resource names
  web_env_name    = local.web_env_name
  worker_env_name = local.worker_env_name
  web_alb_arn     = local.eb_alb_arn

  # Access / IAM / SG / SSH
  office_ip               = data.terraform_remote_state.foundation.outputs.office_ip
  ssh_source_restriction  = local.ssh_source_restriction
  eb_web_app_sg_id        = aws_security_group.eb_web_app_sg.id
  eb_role_arn             = data.terraform_remote_state.foundation.outputs.iam_resources.elastic_beanstalk.role_arn
  eb_instance_profile_arn = data.terraform_remote_state.foundation.outputs.iam_resources.elastic_beanstalk.instance_profile_arn

  # SSL / LB / Listeners / Proxy
  ssl_certificate_arn = data.terraform_remote_state.foundation.outputs.ssl_certificate_arn
  load_balancer_type  = local.load_balancer_type
  listener_enabled    = local.listener_enabled
  process_port        = local.process_port
  listener_protocol   = local.listener_protocol
  ssl_policy          = local.ssl_policy
  stickiness_enabled  = local.stickiness_enabled
  proxy_server        = local.proxy_server

  # Notifications (SNS)
  notification_endpoint = local.notification_endpoint
  notification_protocol = local.notification_protocol

  # Logs & monitoring
  stream_logs             = local.stream_logs
  log_retention_in_days   = local.log_retention_in_days
  log_publication_control = local.log_publication_control

  # networking
  vpc_id             = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  private_subnet_ids = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.private_ids
  public_subnet_ids  = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.public_ids

  # Deploy / Scaling / Env type
  deployment_policy       = local.deployment_policy
  worker_environment_type = local.worker_environment_type
  asg_min_size            = local.asg_min_size
  asg_max_size            = local.asg_max_size

  # Scaling triggers
  asg_measure_name                 = local.asg_measure_name
  asg_statistic                    = local.asg_statistic
  asg_unit                         = local.asg_unit
  asg_period                       = local.asg_period
  asg_evaluation_periods           = local.asg_evaluation_periods
  asg_breach_duration              = local.asg_breach_duration
  asg_upper_threshold              = local.asg_upper_threshold
  asg_lower_threshold              = local.asg_lower_threshold
  asg_upper_breach_scale_increment = local.asg_upper_breach_scale_increment
  asg_lower_breach_scale_increment = local.asg_lower_breach_scale_increment

  # PHP
  document_root          = local.document_root
  php_max_execution_time = local.php_max_execution_time
  php_memory_limit       = local.php_memory_limit

  # Managed updates
  managed_actions_enabled      = local.managed_actions_enabled
  managed_update_level         = local.managed_update_level
  managed_preferred_start_time = local.managed_preferred_start_time

  # Health
  health_config_document = local.health_config_document

  # Database – Test
  db_connection          = data.terraform_remote_state.foundation.outputs.db_rds.connection
  db_connection_readonly = data.terraform_remote_state.foundation.outputs.db_rds.connection_readonly
  db_database            = data.terraform_remote_state.foundation.outputs.db_rds.database
  
  # Primary DB host: live alias → stable fallback → "none"
  db_host = trimsuffix(
    coalesce(
      try(data.terraform_remote_state.data.outputs.mysql_aliases.live.fqdn, null),
      try(data.terraform_remote_state.data.outputs.db_dns_instance_endpoint, null),
      "none"
    ),
    "."
  )

  # Read-only DB host: live RO alias → live alias → stable fallback → "none"
  db_host_readonly = trimsuffix(
    coalesce(
      try(data.terraform_remote_state.data.outputs.mysql_aliases.live_ro.fqdn, null),
      try(data.terraform_remote_state.data.outputs.db_ro_dns_instance_endpoint, null),
      "none"
    ),
    "."
  )

  db_password = data.terraform_remote_state.foundation.outputs.db_rds.password
  db_port     = data.terraform_remote_state.foundation.outputs.db_rds.port
  db_username = data.terraform_remote_state.foundation.outputs.db_rds.username

  # Redis (EC2)
  redis_private_ip = module.ec2-redis[0].redis_private_ip
  redis_client     = data.terraform_remote_state.foundation.outputs.ec2_redis.client
  redis_password   = data.terraform_remote_state.foundation.outputs.ec2_redis.password
  redis_port       = data.terraform_remote_state.foundation.outputs.ec2_redis.port

  # foundation app settings
  app_env                     = data.terraform_remote_state.foundation.outputs.eb_api.APP_ENV
  app_url                     = data.terraform_remote_state.foundation.outputs.eb_api.APP_URL
  aws_region                  = data.terraform_remote_state.foundation.outputs.eb_api.AWS_REGION
  aws_sqs_prefix              = data.terraform_remote_state.foundation.outputs.eb_api.AWS_SQS_PREFIX
  aws_sqs_driver              = data.terraform_remote_state.foundation.outputs.eb_api.AWS_SQS_DRIVER
  broadcast_driver            = data.terraform_remote_state.foundation.outputs.eb_api.BROADCAST_DRIVER
  cache_driver                = data.terraform_remote_state.foundation.outputs.eb_api.CACHE_DRIVER
  can_run_schedule            = data.terraform_remote_state.foundation.outputs.eb_api.CAN_RUN_SCHEDULE
  mandrill_secret             = data.terraform_remote_state.foundation.outputs.eb_api.MANDRILL_SECRET
  bank_of_england_api_url     = data.terraform_remote_state.foundation.outputs.eb_api.BANK_OF_ENGLAND_API_URL
  send_local_emails           = data.terraform_remote_state.foundation.outputs.eb_api.SEND_LOCAL_EMAILS
  get_address_location_key    = data.terraform_remote_state.foundation.outputs.eb_api.GET_ADDRESS_LOCATION_KEY
  connected_stripe_account_id = data.terraform_remote_state.foundation.outputs.eb_api.CONNECTED_STRIPE_ACCOUNT_ID
  personal_agreement_url      = data.terraform_remote_state.foundation.outputs.eb_api.PERSONAL_AGREEMENT_URL
  corporate_agreement_url     = data.terraform_remote_state.foundation.outputs.eb_api.CORPORATE_AGREEMENT_URL
  bank_of_england_api_key     = data.terraform_remote_state.foundation.outputs.eb_api.BANK_OF_ENGLAND_API_KEY

  # Mangopay
  mangopay_client                                 = data.terraform_remote_state.foundation.outputs.eb_api.MANGOPAY_CLIENT
  mangopay_passphrase                             = data.terraform_remote_state.foundation.outputs.eb_api.MANGOPAY_PASSPHRASE
  mangopay_redirect_url                           = data.terraform_remote_state.foundation.outputs.eb_api.MANGOPAY_REDIRECT_URL
  mangopay_url                                    = data.terraform_remote_state.foundation.outputs.eb_api.MANGOPAY_URL
  mangopay_max_funds_per_transaction_for_topup    = data.terraform_remote_state.foundation.outputs.eb_api.MANGOPAY_MAX_FUNDS_PER_TRANSACTION_FOR_TOPUP
  mangopay_topup_funds_limit_without_mangopay_aml = data.terraform_remote_state.foundation.outputs.eb_api.MANGOPAY_TOPUP_FUNDS_LIMIT_WITHOUT_MANGOPAY_AML

  # Queues
  aws_sqs_queue_name = data.terraform_remote_state.foundation.outputs.eb_api.WORKER_QUEUE_NAME
  queue_default      = data.terraform_remote_state.foundation.outputs.eb_api.QUEUE_DEFAULT
  queue_connection   = data.terraform_remote_state.foundation.outputs.eb_api.QUEUE_CONNECTION
  aws_sqs_region     = data.terraform_remote_state.foundation.outputs.eb_api.AWS_SQS_REGION

  # -------------------------
  # Worker / SQSD (required)
  # -------------------------
  sqsd_http_path          = local.sqsd_http_path
  sqsd_http_connections   = local.sqsd_http_connections
  sqsd_visibility_timeout = local.sqsd_visibility_timeout
  sqsd_max_retries        = local.sqsd_max_retries
  sqsd_inactivity_timeout = local.sqsd_inactivity_timeout

  # -------------------------
  # Worker flags / routes
  # -------------------------
  worker_can_run_schedule       = data.terraform_remote_state.foundation.outputs.eb_api.CAN_RUN_SCHEDULE
  register_worker_routes        = data.terraform_remote_state.foundation.outputs.eb_api.REGISTER_WORKER_ROUTES
  worker_register_worker_routes = data.terraform_remote_state.foundation.outputs.eb_api.REGISTER_WORKER_ROUTES

  # Sessions & logging
  session_driver                = data.terraform_remote_state.foundation.outputs.eb_api.SESSION_DRIVER
  session_secure_cookie         = data.terraform_remote_state.foundation.outputs.eb_api.SESSION_SECURE_COOKIE
  app_log_level                 = data.terraform_remote_state.foundation.outputs.eb_api.APP_LOG_LEVEL
  app_debug                     = data.terraform_remote_state.foundation.outputs.eb_api.APP_DEBUG
  composer_home                 = data.terraform_remote_state.foundation.outputs.eb_api.COMPOSER_HOME
  telescope_enabled             = data.terraform_remote_state.foundation.outputs.eb_api.TELESCOPE_ENABLED
  activity_logger_enabled       = data.terraform_remote_state.foundation.outputs.eb_api.ACTIVITY_LOGGER_ENABLED
  activity_logger_db_connection = data.terraform_remote_state.foundation.outputs.eb_api.ACTIVITY_LOGGER_DB_CONNECTION
  log_channel                   = data.terraform_remote_state.foundation.outputs.eb_api.LOG_CHANNEL

  # Email
  mail_driver     = data.terraform_remote_state.foundation.outputs.eb_api.MAIL_DRIVER
  mail_host       = data.terraform_remote_state.foundation.outputs.eb_api.MAIL_HOST
  mail_port       = data.terraform_remote_state.foundation.outputs.eb_api.MAIL_PORT
  mail_username   = data.terraform_remote_state.foundation.outputs.eb_api.MAIL_USERNAME
  mail_password   = data.terraform_remote_state.foundation.outputs.eb_api.MAIL_PASSWORD
  mail_encryption = data.terraform_remote_state.foundation.outputs.eb_api.MAIL_ENCRYPTION
  mandrill_apikey = data.terraform_remote_state.foundation.outputs.eb_api.MANDRILL_APIKEY
  ses_key         = data.terraform_remote_state.foundation.outputs.eb_api.SES_KEY
  ses_secret      = data.terraform_remote_state.foundation.outputs.eb_api.SES_SECRET
  ses_region      = data.terraform_remote_state.foundation.outputs.eb_api.SES_REGION

  # Stripe
  stripe_publishable_key = data.terraform_remote_state.foundation.outputs.eb_api.STRIPE_PUBLISHABLE_KEY
  stripe_secret_key      = data.terraform_remote_state.foundation.outputs.eb_api.STRIPE_SECRET_KEY

  # Twilio
  twilio_account_sid = data.terraform_remote_state.foundation.outputs.eb_api.TWILIO_ACCOUNT_SID
  twilio_auth_token  = data.terraform_remote_state.foundation.outputs.eb_api.TWILIO_AUTH_TOKEN

  # Intercom & Hubspot
  intercom_integration = data.terraform_remote_state.foundation.outputs.eb_api.INTERCOM_INTEGRATION
  hubspot_access_token = data.terraform_remote_state.foundation.outputs.eb_api.HUBSPOT_ACCESS_TOKEN

  # DocuSign
  docusign_account_id    = data.terraform_remote_state.foundation.outputs.eb_api.DOCUSIGN_ACCOUNT_ID
  docusign_client_id     = data.terraform_remote_state.foundation.outputs.eb_api.DOCUSIGN_CLIENT_ID
  docusign_client_secret = data.terraform_remote_state.foundation.outputs.eb_api.DOCUSIGN_CLIENT_SECRET
  docusign_api_url       = data.terraform_remote_state.foundation.outputs.eb_api.DOCUSIGN_API_URL
  docusign_base_url      = data.terraform_remote_state.foundation.outputs.eb_api.DOCUSIGN_BASE_URL

  # Onfido
  onfido_web_api_key        = data.terraform_remote_state.foundation.outputs.eb_api.ONFIDO_WEB_API_KEY
  onfido_mob_api_key        = data.terraform_remote_state.foundation.outputs.eb_api.ONFIDO_MOB_API_KEY
  onfido_mob_application_id = data.terraform_remote_state.foundation.outputs.eb_api.ONFIDO_MOB_APPLICATION_ID

  # Module/stack tags
  tags = local.tags

  # foundation – General
  app_key                     = data.terraform_remote_state.foundation.outputs.eb_api.APP_KEY
  aws_access_key_id           = data.terraform_remote_state.foundation.outputs.eb_api.AWS_ACCESS_KEY_ID
  aws_secret_access_key       = data.terraform_remote_state.foundation.outputs.eb_api.AWS_SECRET_ACCESS_KEY
  aws_default_region          = data.terraform_remote_state.foundation.outputs.eb_api.AWS_DEFAULT_REGION
  kuflink_codestar_connection = data.terraform_remote_state.foundation.outputs.staging_codestar_connection

  # -------------------------
  # CodePipeline (in-module)
  # -------------------------
  pipeline_name         = local.pipeline_name
  pipeline_type         = local.pipeline_type
  execution_mode        = local.execution_mode
  codepipeline_role_arn = local.codepipeline_role_arn

  # Artifact store / S3
  artifact_bucket_name             = local.artifact_bucket_name
  artifact_store_type              = local.artifact_store_type
  artifact_bucket_force_destroy    = local.artifact_bucket_force_destroy
  artifact_bucket_prevent_destroy  = local.artifact_bucket_prevent_destroy
  artifact_bucket_tags             = local.artifact_bucket_tags
  enable_versioning                = local.enable_versioning
  enable_bucket_cleanup_on_destroy = local.enable_bucket_cleanup_on_destroy
  enable_pre_delete_cleanup        = local.enable_pre_delete_cleanup

  aws_cli_region = local.aws_cli_region

  # Source stage (CodeStar)
  source_stage_name       = local.source_stage_name
  source_action_name      = local.source_action_name
  source_owner            = local.source_owner
  source_provider         = local.source_provider
  source_version          = local.source_version
  source_output_artifact  = local.source_output_artifact
  codestar_connection_arn = local.codestar_connection_arn
  full_repository_id      = local.full_repository_id
  branch_name             = local.branch_name

  # Deploy stage (Elastic Beanstalk)
  deploy_stage_name          = local.deploy_stage_name
  deploy_action_name_web     = local.deploy_action_name_web
  deploy_action_name_worker  = local.deploy_action_name_worker
  deploy_owner               = local.deploy_owner
  deploy_provider            = local.deploy_provider
  deploy_version             = local.deploy_version
  enable_worker_deploy       = local.enable_worker_deploy
  eb_application_name        = local.name_prefix_upper
  eb_web_environment_name    = local.web_env_name
  eb_worker_environment_name = local.worker_env_name
}