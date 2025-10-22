# environments/test/foundation/iam_outputs.tf

output "iam_resources" {
  description = "All IAM roles and instance profiles grouped"
  value = {
    # CodeDeploy Service Role
    code_deploy = {
      role_arn = module.iam.codedeploy_service_role_arn
    }

    # DBT
    dbt = {
      role_arn              = module.iam.dbt_role_arn
      instance_profile_name = module.iam.dbt_ec2_instance_profile_name
    }

    # Redis
    redis = {
      role_arn              = module.iam.redis_role_arn
      instance_profile_name = module.iam.redis_ec2_instance_profile_name
    }

    # Bastion
    bastion = {
      role_arn              = module.iam.bastion_role_arn
      instance_profile_name = module.iam.bastion_ec2_instance_profile_name
    }

    # Backup
    backup = {
      role_arn = module.iam.backup_role_arn
    }

    # EC2 Test
    ec2_test = {
      role_arn = module.iam.ec2_test_instance_role_arn
    }

    # Lambda
    lambda = {
      role_arn = module.iam.lambda_role_arn
    }

    # Elastic Beanstalk
    elastic_beanstalk = {
      role_arn              = module.iam.eb_role_arn
      instance_profile_arn  = module.iam.eb_instance_profile_arn
      codepipeline_role_arn = module.iam.eb_codepipeline_role_arn
    }

    # S3 Frontend
    s3_frontend = {
      codepipeline_role_arn = module.iam.s3_frontend_codepipeline_role_arn
      codebuild_role_arn    = module.iam.s3_frontend_codebuild_role_arn
    }

    # S3 Admin
    s3_admin = {
      codepipeline_role_arn = module.iam.s3_admin_codepipeline_role_arn
      codebuild_role_arn    = module.iam.s3_admin_codebuild_role_arn
    }

    # Metabase
    metabase = {
      instance_profile_name = module.iam.metabase_ec2_instance_profile_name
    }

    # Redshift
    redshift = {
      dms_role_arn = module.iam.redshift_dms_role_arn
      role_arn     = module.iam.redshift_role_arn
    }

    # DMS
    dms = {
      role_arn                      = module.iam.dms_role_arn
      access_for_endpoint_role_name = module.iam.dms_access_for_endpoint_role_name
      access_for_endpoint_role_arn  = module.iam.dms_access_for_endpoint_role_arn
      cloudwatch_logs_role_arn      = module.iam.dms_cloudwatch_logs_role_arn
    }

    # RDS Enhanced Monitoring
    rds_enhanced_monitoring = {
      role_name = module.iam.rds_enhanced_monitoring_role_name
      role_arn  = module.iam.rds_enhanced_monitoring_role_arn
    }
  }
  sensitive = false
}