output "dbt_role_arn" {
  description = "ARN of the IAM dbt Role"
  value       = module.iam.dbt_role_arn
}

output "dbt_ec2_instance_profile_name" {
  description = "DBT EC2 Instance Profile Name"
  value       = module.iam.dbt_ec2_instance_profile_name
}

output "redis_role_arn" {
  description = "ARN of the IAM redis Role"
  value       = module.iam.redis_role_arn
}

output "redis_ec2_instance_profile_name" {
  description = "redis EC2 Instance Profile Name"
  value       = module.iam.redis_ec2_instance_profile_name
}

output "bastion_role_arn" {
  description = "ARN of the IAM Bastion Role"
  value       = module.iam.bastion_role_arn
}

output "bastion_ec2_instance_profile_name" {
  description = "Bastion EC2 Instance Profile Name"
  value       = module.iam.bastion_ec2_instance_profile_name
}

output "backup_role_arn" {
  description = "ARN of the IAM Backup Role"
  value       = module.iam.backup_role_arn
}

output "ec2_test_instance_role_arn" {
  description = "ARN of the EC2 test instance IAM Role"
  value       = module.iam.ec2_test_instance_role_arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM Role"
  value       = module.iam.lambda_role_arn
}

output "eb_role_arn" {
  description = "ARN of the Elastic Beanstalk IAM Role"
  value       = module.iam.eb_role_arn
}

output "eb_instance_profile_arn" {
  description = "ARN of the Elastic Beanstalk EC2 Instance Profile"
  value       = module.iam.eb_instance_profile_arn
}

output "eb_codepipeline_role_arn" {
  description = "ARN of the Elastic Beanstalk CodePipeline IAM Role"
  value       = module.iam.eb_codepipline_role_arn
}

output "s3_frontend_codepipeline_role_arn" {
  description = "ARN of the S3 Frontend CodePipeline IAM Role"
  value       = module.iam.s3_frontend_codepipeline_role_arn
}

output "s3_frontend_codebuild_role_arn" {
  description = "ARN of the S3 Frontend Code Build  IAM Role"
  value       = module.iam.s3_frontend_codebuild_role_arn
}

output "s3_admin_codepipeline_role_arn" {
  description = "ARN of the S3 admin CodePipeline IAM Role"
  value       = module.iam.s3_admin_codepipeline_role_arn
}

output "s3_admin_codebuild_role_arn" {
  description = "ARN of the S3 admin Code Build  IAM Role"
  value       = module.iam.s3_admin_codebuild_role_arn
}

output "metabase_ec2_instance_profile_name" {
  description = "Metabase EC2 Instance Profile Name"
  value       = module.iam.metabase_ec2_instance_profile_name
}

output "redshift_dms_role_arn" {
  description = "ARN of the Redshift DMS Role"
  value       = module.iam.redshift_dms_role_arn
}

output "redshift_role_arn" {
  description = "ARN of the Redshift Role"
  value       = module.iam.redshift_role_arn
}

output "dms_role_arn" {
  description = "ARN of the DMS Role"
  value       = module.iam.dms_role_arn
}

output "dms_access_for_endpoint_role_name" {
  description = "Name of the DMS access-for-endpoint Role"
  value       = module.iam.dms_access_for_endpoint_role_name
}

output "dms_access_for_endpoint_role_arn" {
  description = "ARN of the DMS access-for-endpoint Role"
  value       = module.iam.dms_access_for_endpoint_role_arn
}

output "dms_cloudwatch_logs_role_arn" {
  description = "ARN of the DMS CloudWatch Logs Role"
  value       = module.iam.dms_cloudwatch_logs_role_arn
}


# output "dms_assessment_role_arn" {
#   description = "ARN of the DMS Assessment Role"
#   value       = module.iam.dms_assessment_role_arn
# }

output "rds_enhanced_monitoring_role_name" {
  description = "Name of the RDS Ehanced Monitoring Role"
  value       = module.iam.rds_enhanced_monitoring_role_name
}

output "rds_enhanced_monitoring_role_arn" {
  description = "ARN of the RDS Ehanced Monitoring Role"
  value       = module.iam.rds_enhanced_monitoring_role_arn
}
