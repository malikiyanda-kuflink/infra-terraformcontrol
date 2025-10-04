resource "aws_wafv2_web_acl_association" "eb_alb" {
  count = local.enable_eb && local.enable_eb_waf ? 1 : 0

  resource_arn = local.eb_alb_arn
  web_acl_arn  = module.eb_waf[0].web_acl_arn

  depends_on = [
    module.eb-api,
    module.eb_waf
  ]
}

module "eb-api" {
  count  = local.enable_eb ? 1 : 0
  source = "git::ssh://git@github.com/malikiyanda-kuflink/infra-terraformcontrol.git//modules/eb-api?ref=v0.1.92"

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

  # Access / IAM / SG / SSH
  office_ip               = data.terraform_remote_state.foundation.outputs.office_ip
  ssh_source_restriction  = local.ssh_source_restriction
  eb_web_app_sg_id        = aws_security_group.eb_web_app_sg.id
  eb_role_arn             = data.terraform_remote_state.foundation.outputs.eb_role_arn
  eb_instance_profile_arn = data.terraform_remote_state.foundation.outputs.eb_instance_profile_arn

  # SSL / LB / Listeners / Proxy
  ssl_certificate_arn = data.terraform_remote_state.foundation.outputs.brickfin_ssl_acm
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
  vpc_id             = data.terraform_remote_state.foundation.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.foundation.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.foundation.outputs.public_subnet_ids

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
  db_connection          = data.terraform_remote_state.foundation.outputs.db_test_connection
  db_connection_readonly = data.terraform_remote_state.foundation.outputs.db_test_connection_readonly
  db_database            = data.terraform_remote_state.foundation.outputs.db_test_database
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

  db_password = data.terraform_remote_state.foundation.outputs.db_test_password
  db_port     = data.terraform_remote_state.foundation.outputs.db_test_port
  db_username = data.terraform_remote_state.foundation.outputs.db_test_username

  # Redis (EC2)
  redis_private_ip = module.ec2-redis[0].redis_private_ip
  redis_client     = data.terraform_remote_state.foundation.outputs.redis_test_client
  redis_password   = data.terraform_remote_state.foundation.outputs.redis_test_password
  redis_port       = data.terraform_remote_state.foundation.outputs.redis_test_port

  # Redis (ElastiCache)
  # redis_endpoint                 = module.redis_elastic_cache.redis_endpoint
  # redis_elastic_cache_php_client = data.terraform_remote_state.foundation.outputs.redis_elastic_cache_php_client
  # redis_elastic_cache_password   = data.terraform_remote_state.foundation.outputs.redis_elastic_cache_password
  # redis_elastic_cache_port       = data.terraform_remote_state.foundation.outputs.redis_elastic_cache_port

  # foundation app settings
  app_env                     = data.terraform_remote_state.foundation.outputs.app_env
  app_url                     = data.terraform_remote_state.foundation.outputs.app_url
  aws_region                  = data.terraform_remote_state.foundation.outputs.aws_region
  aws_sqs_prefix              = data.terraform_remote_state.foundation.outputs.aws_sqs_prefix
  aws_sqs_driver              = data.terraform_remote_state.foundation.outputs.aws_sqs_driver
  broadcast_driver            = data.terraform_remote_state.foundation.outputs.broadcast_driver
  cache_driver                = data.terraform_remote_state.foundation.outputs.cache_driver
  can_run_schedule            = data.terraform_remote_state.foundation.outputs.can_run_schedule
  mandrill_secret             = data.terraform_remote_state.foundation.outputs.mandrill_secret
  bank_of_england_api_url     = data.terraform_remote_state.foundation.outputs.bank_of_england_api_url
  send_local_emails           = data.terraform_remote_state.foundation.outputs.send_local_emails
  get_address_location_key    = data.terraform_remote_state.foundation.outputs.get_address_location_key
  connected_stripe_account_id = data.terraform_remote_state.foundation.outputs.connected_stripe_account_id
  personal_agreement_url      = data.terraform_remote_state.foundation.outputs.personal_agreement_url
  corporate_agreement_url     = data.terraform_remote_state.foundation.outputs.corporate_agreement_url
  bank_of_england_api_key     = data.terraform_remote_state.foundation.outputs.bank_of_england_api_key

  # Mangopay
  mangopay_client                                 = data.terraform_remote_state.foundation.outputs.mangopay_client
  mangopay_passphrase                             = data.terraform_remote_state.foundation.outputs.mangopay_passphrase
  mangopay_redirect_url                           = data.terraform_remote_state.foundation.outputs.mangopay_redirect_url
  mangopay_url                                    = data.terraform_remote_state.foundation.outputs.mangopay_url
  mangopay_max_funds_per_transaction_for_topup    = data.terraform_remote_state.foundation.outputs.mangopay_max_funds_per_transaction_for_topup
  mangopay_topup_funds_limit_without_mangopay_aml = data.terraform_remote_state.foundation.outputs.mangopay_topup_funds_limit_without_mangopay_aml

  # Queues
  aws_sqs_queue_name = local.worker_queue_name
  queue_default      = data.terraform_remote_state.foundation.outputs.queue_default
  queue_connection   = data.terraform_remote_state.foundation.outputs.queue_connection
  aws_sqs_region     = data.terraform_remote_state.foundation.outputs.aws_sqs_region


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
  worker_can_run_schedule       = data.terraform_remote_state.foundation.outputs.worker_can_run_schedule
  register_worker_routes        = data.terraform_remote_state.foundation.outputs.register_worker_routes
  worker_register_worker_routes = data.terraform_remote_state.foundation.outputs.worker_register_worker_routes

  # Sessions & logging
  session_driver                = data.terraform_remote_state.foundation.outputs.session_driver
  session_secure_cookie         = data.terraform_remote_state.foundation.outputs.session_secure_cookie
  app_log_level                 = data.terraform_remote_state.foundation.outputs.app_log_level
  app_debug                     = data.terraform_remote_state.foundation.outputs.app_debug
  composer_home                 = data.terraform_remote_state.foundation.outputs.composer_home
  telescope_enabled             = data.terraform_remote_state.foundation.outputs.telescope_enabled
  activity_logger_enabled       = data.terraform_remote_state.foundation.outputs.activity_logger_enabled
  activity_logger_db_connection = data.terraform_remote_state.foundation.outputs.activity_logger_db_connection
  log_channel                   = data.terraform_remote_state.foundation.outputs.log_channel

  # Email
  mail_driver     = data.terraform_remote_state.foundation.outputs.mail_driver
  mail_host       = data.terraform_remote_state.foundation.outputs.mail_host
  mail_port       = data.terraform_remote_state.foundation.outputs.mail_port
  mail_username   = data.terraform_remote_state.foundation.outputs.mail_username
  mail_password   = data.terraform_remote_state.foundation.outputs.mail_password
  mail_encryption = data.terraform_remote_state.foundation.outputs.mail_encryption
  mandrill_apikey = data.terraform_remote_state.foundation.outputs.mandrill_apikey
  ses_key         = data.terraform_remote_state.foundation.outputs.ses_key
  ses_secret      = data.terraform_remote_state.foundation.outputs.ses_secret
  ses_region      = data.terraform_remote_state.foundation.outputs.ses_region

  # Stripe
  stripe_publishable_key = data.terraform_remote_state.foundation.outputs.stripe_publishable_key
  stripe_secret_key      = data.terraform_remote_state.foundation.outputs.stripe_secret_key

  # Twilio
  twilio_account_sid = data.terraform_remote_state.foundation.outputs.twilio_account_sid
  twilio_auth_token  = data.terraform_remote_state.foundation.outputs.twilio_auth_token

  # Intercom & Hubspot
  intercom_integration = data.terraform_remote_state.foundation.outputs.intercom_integration
  hubspot_access_token = data.terraform_remote_state.foundation.outputs.hubspot_access_token

  # DocuSign
  docusign_account_id    = data.terraform_remote_state.foundation.outputs.docusign_account_id
  docusign_client_id     = data.terraform_remote_state.foundation.outputs.docusign_client_id
  docusign_client_secret = data.terraform_remote_state.foundation.outputs.docusign_client_secret
  docusign_api_url       = data.terraform_remote_state.foundation.outputs.docusign_api_url
  docusign_base_url      = data.terraform_remote_state.foundation.outputs.docusign_base_url

  # Onfido
  onfido_web_api_key        = data.terraform_remote_state.foundation.outputs.onfido_web_api_key
  onfido_mob_api_key        = data.terraform_remote_state.foundation.outputs.onfido_mob_api_key
  onfido_mob_application_id = data.terraform_remote_state.foundation.outputs.onfido_mob_application_id

  # Module/stack tags
  tags = local.tags

  # foundation – General
  app_key                     = data.terraform_remote_state.foundation.outputs.app_key
  aws_access_key_id           = data.terraform_remote_state.foundation.outputs.aws_access_key_id
  aws_secret_access_key       = data.terraform_remote_state.foundation.outputs.aws_secret_access_key
  aws_default_region          = data.terraform_remote_state.foundation.outputs.aws_default_region
  kuflink_codestar_connection = data.terraform_remote_state.foundation.outputs.kuflink_codestar_connection

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