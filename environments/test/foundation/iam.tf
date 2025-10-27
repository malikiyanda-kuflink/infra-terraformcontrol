module "iam" {
  source = "../../../modules/iam"

  name_prefix = local.name_prefix

  # -------------------------------------------------
  # Feature toggles 
  # -------------------------------------------------
  enable_redis_role                    = true
  enable_backup_role                   = true
  enable_bastion_role                  = true
  enable_ec2_test_instance_role        = true
  enable_dms_role                      = true
  enable_dms_cw_logs_role              = true
  enable_dms_access_for_endpoint_role  = true
  enable_eb_role                       = true
  enable_eb_codepipeline_role          = true
  enable_lambda_role                   = true
  enable_s3_frontend_codebuild_role    = true
  enable_s3_frontend_codepipeline_role = true
  enable_s3_admin_codepipeline_role    = true
  enable_s3_admin_codebuild_role       = true
  enable_dbt_role                      = true
  enable_rds_enhanced_monitoring_role  = true
  enable_codedeploy_service_role       = true

  enable_metabase_role     = true
  enable_redshift_role     = true
  enable_redshift_dms_role = true


  # -------------------------------------------------
  # Role Naming 
  # -------------------------------------------------
  dbt_role_name     = "${local.name_prefix}-dbt-role"
  redis_role_name   = "${local.name_prefix}-redis-role"
  bastion_role_name = "${local.name_prefix}-bastion-role"
  backup_role_name  = "${local.name_prefix}-backup-role"

  dms_role_name                     = "${local.name_prefix}-dms-role"
  dms_cloudwatch_logs_role_name     = "${local.name_prefix}-dms-cloudwatch-logs-role"
  dms_access_for_endpoint_role_name = "${local.name_prefix}-dms-access-for-endpoint-role"

  ec2_test_instance_role_name        = "${local.name_prefix}-ec2-role"
  eb_role_name                       = "${local.name_prefix}-eb-ec2-role"
  eb_instance_profile_name           = "${local.name_prefix}-eb-ec2-profile"
  eb_codepipeline_role_name          = "${local.name_prefix}-eb-codepipline-role"
  s3_frontend_codebuild_role_name    = "${local.name_prefix}-s3-frontend-codebuild-role"
  s3_frontend_codepipeline_role_name = "${local.name_prefix}-s3-frontend-codepipline-role"
  s3_admin_codepipeline_role_name    = "${local.name_prefix}-s3-admin-codepipline-role"
  s3_admin_codebuild_role_name       = "${local.name_prefix}-s3-admin-codebuild-role"
  metabase_role_name                 = "${local.name_prefix}-metabase-ec2-role"
  lambda_role_name                   = "${local.name_prefix}-lambda-role"
  redshift_endpoint_role_name        = "${local.name_prefix}-redshift-dms-role"
  redshift_role_name                 = "${local.name_prefix}-redshift-role"
  rds_enhanced_monitoring_role_name  = "${local.name_prefix}-rds-enhanced-monitoring-role"
  codedeploy_service_role_name       = "${local.name_prefix}-codedeploy-service-role"

  tags = {
    Project = "Kuflink"
  }
}