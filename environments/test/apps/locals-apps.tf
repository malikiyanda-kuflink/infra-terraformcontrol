# ===================================================================
# ACCOUNT / REGION / PARTITION DISCOVERY
# These data sources expose the current AWS account ID, region, and
# partition so they can be interpolated elsewhere in this file.
# ===================================================================
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}


# ===================================================================
# LOCALS
# This section centralizes toggles, names, environment controls,
# WAF, Redis, EB, and CodePipeline configuration. Values here are
# referenced throughout the compute and delivery layers.
# ===================================================================
locals {
  # DBT EC2 Configuration
  dbt_config = {
    environment              = "test"
    ssh_key_name             = data.terraform_remote_state.foundation.outputs.global.ec2_key_name
    instance_type            = "t3.micro"
    dbt_name                 = "Kuflink-Test-DBT"
    dbt_docs_subdomain       = "dbt-test.${data.terraform_remote_state.foundation.outputs.route53_zone_name}"
    code_deploy_project_name = "Kuflink-Test-DBT-Project"
  }

  # Read script and convert to Unix line endings
  dbt_full_script_raw  = file("${path.root}/user-data/dbt_user_data.sh")
  dbt_full_script_unix = replace(local.dbt_full_script_raw, "\r\n", "\n")

  # Minimal user data that decompresses and executes
  dbt_user_data_with_env = <<-EOF
    #!/bin/bash
    set -euo pipefail
    
    export ENV_NAME="${local.dbt_config.environment}"
    export REGION="eu-west-2"
    
    # Decompress and execute the script
    base64 -d <<'SCRIPT_END' | gunzip > /tmp/dbt_setup.sh
    ${base64gzip(local.dbt_full_script_unix)}
    SCRIPT_END
    
    chmod +x /tmp/dbt_setup.sh
    /tmp/dbt_setup.sh 2>&1 | tee /var/log/user-data.log
  EOF




  # =======================================
  # Comptue layer  
  # =======================================
  env         = "test"
  name_prefix = "kuflink-test"

  environment       = "Test"
  name_prefix_upper = "Kuflink-Test"

  aws_route53_zone   = data.terraform_remote_state.foundation.outputs.route53_zone_name
  hosted_zone_id     = data.terraform_remote_state.foundation.outputs.route53_hosted_zone_id
  cloudfront_zone_id = data.terraform_remote_state.foundation.outputs.cloudfront_zone_id
  # -----------------------------------------------------------------
  # Admin (S3 + CLOUDFRONT) TOGGLES / NAMES
  # Enable/disable the static admin, domain mappings, hosted zone
  # selection, and the certificate ARN (must be us-east-1 for CF).
  # 'admin_website_url' resolves to the record FQDN or CF domain.
  # -----------------------------------------------------------------
  # admin_waf_arn     = data.terraform_remote_state.platform.outputs.s3_admin_waf.web_acl_arn
  admin_waf_arn     = local.enable_s3_admin && local.enable_s3_admin_waf ? module.s3_admin_waf[0].web_acl_arn : null
  admin_bucket_name = data.terraform_remote_state.foundation.outputs.s3_admin.bucket_name

  admin_domains     = [data.terraform_remote_state.foundation.outputs.s3_admin.domain]
  admin_record_name = data.terraform_remote_state.foundation.outputs.s3_admin.domain

  # Hosted zone: choose either ID or name.
  admin_hosted_zone_id   = local.hosted_zone_id
  admin_hosted_zone_name = null

  # CloudFront cert (must be in us-east-1)
  admin_cf_cert_arn = data.terraform_remote_state.foundation.outputs.cloudfront_cert_arn

  admin_website_url = local.enable_s3_admin ? coalesce(
    try(aws_route53_record.admin_alias[0].fqdn, null),
    module.s3-admin.cloudfront_domain_name
  ) : null

  # maintenance_admin_website_url = local.enable_s3_admin ? coalesce(
  #   try(aws_route53_record.maintenance_alias_weighted.fqdn, null),
  #   module.s3-admin.cloudfront_domain_name
  # ) : null

  admin_codebuild_email_endpoint = data.terraform_remote_state.foundation.outputs.global.build_notification_email
  admin_codebuild_image          = "aws/codebuild/standard:7.0" # has Node 20
  admin_repo                     = data.terraform_remote_state.foundation.outputs.s3_admin.repo
  admin_api_url                  = data.terraform_remote_state.foundation.outputs.eb_api.API_URL
  admin_branch                   = "test"
  # admin_branch                 = "develop" # debug cors issue - cors.conf
  admin_codestar_connection = data.terraform_remote_state.foundation.outputs.staging_codestar_connection

  # -----------------------------------------------------------------
  # FRONTEND (S3 + CLOUDFRONT) TOGGLES / NAMES
  # Enable/disable the static frontend, domain mappings, hosted zone
  # selection, and the certificate ARN (must be us-east-1 for CF).
  # 'frontend_website_url' resolves to the record FQDN or CF domain.
  # -----------------------------------------------------------------
  api_url                 = data.terraform_remote_state.foundation.outputs.eb_api.API_URL
  frontend_bucket_name    = data.terraform_remote_state.foundation.outputs.s3_frontend.bucket_name
  maintenance_bucket_name = data.terraform_remote_state.foundation.outputs.s3_frontend.maintenance_bucket_name

  frontend_domains     = [data.terraform_remote_state.foundation.outputs.s3_frontend.domain]
  frontend_record_name = data.terraform_remote_state.foundation.outputs.s3_frontend.domain

  # Hosted zone: choose either ID or name.
  frontend_hosted_zone_id   = local.hosted_zone_id
  frontend_hosted_zone_name = null

  # CloudFront cert (must be in us-east-1)
  frontend_cf_cert_arn = data.terraform_remote_state.foundation.outputs.cloudfront_cert_arn

  frontend_website_url = local.enable_s3_frontend ? coalesce(
    try(aws_route53_record.frontend_alias[0].fqdn, null),
    module.s3-frontend.cloudfront_domain_name
  ) : null

  # maintenance_frontend_website_url = local.enable_s3_frontend ? coalesce(
  #   try(aws_route53_record.maintenance_alias_weighted.fqdn, null),
  #   module.s3-frontend.cloudfront_domain_name
  # ) : null

  frontend_codebuild_email_endpoint = data.terraform_remote_state.foundation.outputs.global.build_notification_email
  frontend_codebuild_image          = "aws/codebuild/standard:7.0" # has Node 20
  frontend_repo                     = data.terraform_remote_state.foundation.outputs.s3_frontend.repo
  frontend_branch                   = "staging-test"
  # frontend_branch                 = "develop" # debug cors issue - cors.conf
  frontend_codestar_connection = data.terraform_remote_state.foundation.outputs.staging_codestar_connection


  # --------------------------------------
  # BASTION SETTINGS
  # DNS name, optional EIP exposure (toggle-controlled), SSH tunnel
  # forwarding ports, and RDS endpoint target for jump-box usage.
  # --------------------------------------
  # Bastion locals
  # --------------------------------------
  staging_dns_bastion_name = data.terraform_remote_state.foundation.outputs.ec2_bastion.dns_name

  # Toggle-controlled bastion EIP
  # bastion_eip_public_ip      = module.ec2-bastion.bastion_elastic_ip  
  bastion_eip_public_ip = local.enable_bastion ? module.ec2-bastion[0].bastion_elastic_ip : null

  staging_dns_bastion_target = local.db_endpoint
  forward_port               = data.terraform_remote_state.foundation.outputs.ec2_bastion.forward_port
  target_port                = data.terraform_remote_state.foundation.outputs.ec2_bastion.target_port

  # --------------------------------------
  # ADMIN WAF CONFIGURATION (ENV-SCOPED) FOR EB ALB
  # Master toggle, ALB ARN discovery, rule modes, IP allowlists,
  # managed rule group selection and override behavior, plus logging.
  # --------------------------------------
  # WAF config (env-scoped) - compute layer
  # --------------------------------------
  admin_ip_action        = "BLOCK" # or "COUNT"/ "BLOCK" / "ALLOW" / "CAPTCHA" / "CHALLENGE"
  admin_trusted_ip_cidrs = [for ip in data.terraform_remote_state.foundation.outputs.kuflink_office_ips : ip.cidr]

  admin_waf_enable_groups = {
    common           = true
    ip_reputation    = true
    known_bad_inputs = true
    sqli             = true
    admin_protection = true
    anonymous_ip     = false
  }

  # Set noisy subrules to COUNT (others use default managed action)
  admin_waf_overrides = {
    common           = []
    ip_reputation    = []
    known_bad_inputs = []
    sqli             = []
    admin_protection = []
    anonymous_ip     = ["AnonymousIPList"]
  }

  admin_waf_logging = {
    enabled        = true
    log_group_name = null # let the module default it
    retention_days = 30
    create_policy  = true
  }

  # --------------------------------------
  # WAF CONFIGURATION (ENV-SCOPED) FOR EB ALB
  # Master toggle, ALB ARN discovery, rule modes, IP allowlists,
  # managed rule group selection and override behavior, plus logging.
  # --------------------------------------
  # WAF config (env-scoped) - compute layer
  # --------------------------------------
  # Get ALB ARN directly from EB module output
  eb_alb_arn = local.enable_eb ? try(module.eb-api[0].load_balancer_arn, null) : null
  # Check if ALB exists
  eb_alb_exists = local.eb_alb_arn != null && local.eb_alb_arn != ""

  admin_rule_action = "COUNT" # or "COUNT"/ "BLOCK" / "ALLOW" / "CAPTCHA" / "CHALLENGE"
  trusted_ip_cidrs  = [for ip in data.terraform_remote_state.foundation.outputs.kuflink_office_ips : ip.cidr]
  admin_uri_regexes = [".*/admin/.*", ".*/wp-admin/.*"]

  waf_enable_groups = {
    common           = true
    ip_reputation    = true
    known_bad_inputs = true
    linux            = true
    php              = true
    sqli             = true
    anonymous_ip     = false
  }

  # Set noisy subrules to COUNT (others use default managed action)
  waf_overrides = {
    common           = ["SizeRestrictions_BODY", "CrossSiteScripting_BODY", "CrossSiteScripting_QUERYARGUMENTS", "CrossSiteScripting_COOKIE", "CrossSiteScripting_URIPATH"]
    ip_reputation    = []
    known_bad_inputs = []
    linux            = []
    php              = []
    sqli             = []
    anonymous_ip     = ["AnonymousIPList"]
  }

  waf_logging = {
    enabled        = true
    log_group_name = null # let the module default it
    retention_days = 30
    create_policy  = true
  }

  # --------------------------------------
  # REDIS
  # Name of the SSM parameter that advertises the Redis host to apps.
  # --------------------------------------
  # Redis locals
  # --------------------------------------
  redis_host_param_name = "/backend/${local.env}/REDIS_HOST"

  ############################################
  # ELASTIC BEANSTALK (EB) – APP & ENV PARAMS
  # Naming, platform stack, instance types, proxy config, SSH source,
  # notifications, worker queue (SQSD), scaling, PHP tuning,
  # managed updates, and health reporting.
  ############################################
  # Locals used by the eb-api module call
  ############################################
  # Names / descriptions
  web_env_name            = "Kuflink-${local.environment}-Web"
  worker_env_name         = "Kuflink-${local.environment}-Worker"
  tier                    = "Worker"
  application_description = "${local.environment} Kuflink Laravel 9 Application"
  solution_stack_name     = "64bit Amazon Linux 2023 v4.7.8 running PHP 8.4"
  ec2_key_name            = data.terraform_remote_state.foundation.outputs.global.ec2_key_name
  github_branch           = "test"
  web_instance_type       = "t3.medium"
  worker_instance_type    = "t3.large"


  # ALB / listeners / proxy
  load_balancer_type = "application"
  listener_enabled   = "true" # EB expects string "true"/"false" in settings
  process_port       = "80"
  listener_protocol  = "HTTPS"
  ssl_policy         = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  stickiness_enabled = "false"
  proxy_server       = "nginx"

  # SSH restriction (derived from office_ip if you like)
  ssh_source_restriction = "tcp,22,22,${data.terraform_remote_state.foundation.outputs.office_ip}"

  # Notifications (SNS)
  notification_endpoint = data.terraform_remote_state.foundation.outputs.global.build_notification_email
  notification_protocol = "email"

  # SQSD (Worker)
  worker_queue_name       = data.terraform_remote_state.foundation.outputs.eb_api.WORKER_QUEUE_NAME
  sqsd_http_path          = "/worker/queue"
  sqsd_http_connections   = 100
  sqsd_visibility_timeout = 900
  sqsd_max_retries        = 3
  sqsd_inactivity_timeout = 899

  # Tags
  tags = {
    Environment = local.environment
    Application = "Kuflink"
    Stack       = "EB"
  }

  # Logs & monitoring
  stream_logs             = true
  log_retention_in_days   = 30
  log_publication_control = true
  alb_log_bucket          = "${local.name_prefix}-alb-logs"
  alb_conn_log_prefix     = "conn"

  # Deploy / scaling
  deployment_policy       = "AllAtOnce"
  worker_environment_type = "SingleInstance"
  asg_min_size            = 1
  asg_max_size            = 3

  # Scaling triggers
  asg_measure_name                 = "CPUUtilization"
  asg_statistic                    = "Average"
  asg_unit                         = "Percent"
  asg_period                       = 5
  asg_evaluation_periods           = 2
  asg_breach_duration              = 20
  asg_upper_threshold              = 95
  asg_lower_threshold              = 10
  asg_upper_breach_scale_increment = 1
  asg_lower_breach_scale_increment = -1

  # PHP
  document_root          = "/public"
  php_max_execution_time = "600"
  php_memory_limit       = "2048M"

  # Managed updates
  managed_actions_enabled      = true
  managed_update_level         = "minor" # or "patch"
  managed_preferred_start_time = "Sat:04:00"

  # Health reporting (JSON as string)
  health_config_document = jsonencode({
    Version = 1,
    Rules = {
      Environment = {
        Application = {
          ApplicationRequests4xx = { Enabled = false }
        }
      }
    }
  })

  # -------------------------
  # CODEPIPELINE – CORE NAMING
  # Binds the pipeline to the EB app (or a fallback), sets pipeline
  # naming/mode, and version (V2).
  # -------------------------
  # CodePipeline core
  # -------------------------
  eb_app_name            = local.name_prefix_upper
  pipeline_name          = "${local.eb_app_name}-api-pipeline"
  codepipeline_role_name = "${local.eb_app_name}-API-Pipeline-Role"
  pipeline_type          = "V2"
  execution_mode         = "QUEUED" # or "PARALLEL"

  # -------------------------
  # ARTIFACT STORE (S3)
  # S3 bucket for pipeline artifacts and housekeeping controls.
  # -------------------------
  # Artifact store / S3
  # -------------------------
  artifact_bucket_name             = "${local.name_prefix}-codepipline-artifacts"
  artifact_store_type              = "S3"
  artifact_bucket_force_destroy    = true
  artifact_bucket_prevent_destroy  = false
  artifact_bucket_tags             = { Name = "${local.name_prefix}-codepipline-artifacts" }
  enable_versioning                = false
  enable_bucket_cleanup_on_destroy = false       # local-exec on bucket destroy
  enable_pre_delete_cleanup        = false       # null_resource to rm objects
  aws_cli_region                   = "eu-west-2" # or "eu-west-2" to force

  # -------------------------
  # SOURCE STAGE (CODESTAR)
  # Wires the pipeline to the GitHub repo via CodeStar connection.
  # -------------------------
  # Source stage (CodeStar)
  # -------------------------
  source_stage_name      = "Source"
  source_action_name     = "Source"
  source_owner           = "AWS"
  source_provider        = "CodeStarSourceConnection"
  source_version         = "1"
  source_output_artifact = "source_output"

  codestar_connection_arn = data.terraform_remote_state.foundation.outputs.staging_codestar_connection
  codepipeline_role_arn   = data.terraform_remote_state.foundation.outputs.iam_resources.elastic_beanstalk.codepipeline_role_arn
  full_repository_id      = data.terraform_remote_state.foundation.outputs.eb_api.API_REPO
  branch_name             = "test"

  # -------------------------
  # DEPLOY STAGE (ELASTIC BEANSTALK)
  # Defines CodePipeline actions to deploy to EB Web/Worker envs.
  # -------------------------
  # Deploy stage (Elastic Beanstalk)
  # -------------------------
  deploy_stage_name         = "Deploy"
  deploy_action_name_web    = "Deploy"
  deploy_action_name_worker = "DeployWorker"
  deploy_owner              = "AWS"
  deploy_provider           = "ElasticBeanstalk"
  deploy_version            = "1"
  enable_worker_deploy      = true

  # Reuse existing naming locals you already have
  eb_application_name        = local.name_prefix_upper
  eb_web_environment_name    = local.web_env_name
  eb_worker_environment_name = local.worker_env_name

  # --- Elastic Beanstalk notifications ---
  create_eb_topic = true
  # eb_topic_name             = "ElasticBeanstalkNotifications-Deployments-Kuflink-dev-test-web-env"
  eb_topic_name            = "ElasticBeanstalkNotifications-Deployments-${local.web_env_name}" #DO NOT EDIT
  eb_notification_protocol = "email"
  eb_notification_emails   = [data.terraform_remote_state.foundation.outputs.global.build_notification_email]
  # --- Pipeline SNS topic + email subscribers ---
  create_pipeline_topic        = true
  pipeline_topic_name          = "codestar-${local.name_prefix}-backend-pipeline-notifications"
  pipeline_notification_emails = [data.terraform_remote_state.foundation.outputs.global.build_notification_email]

  # --- CodeStar Notifications rule ---
  create_pipeline_notification_rule = true
  pipeline_notification_rule_name   = "${local.name_prefix_upper}-backend-pipeline-notifications"
  pipeline_notification_event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-superseded"
  ]

  # --- Pipeline ARN (derived from name/account/region) ---
  pipeline_arn = "arn:${data.aws_partition.current.partition}:codepipeline:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${local.pipeline_name}"



}
