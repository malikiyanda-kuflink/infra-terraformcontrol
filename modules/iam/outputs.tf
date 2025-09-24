# =====================================================================
# IAM Role Module Outputs
# These outputs expose ARNs / names for IAM roles and instance profiles
# created in this module. All roles are optional and controlled via the
# corresponding enable_* variables.
# =====================================================================

# ----------------------------
# RDS Monitoring Role IAM Role
# ----------------------------
output "rds_enhanced_monitoring_role_arn" {
  description = "ARN of the RDS Monitoring Role IAM Role (if enabled)"
  value = var.enable_rds_enhanced_monitoring_role ? aws_iam_role.rds_enhanced_monitoring_role[0].arn : null
}

output "rds_enhanced_monitoring_role_name" {
  description = "Name of the RDS Monitoring Role IAM Role (if enabled)"
  value = var.enable_rds_enhanced_monitoring_role ? aws_iam_role.rds_enhanced_monitoring_role[0].name : null
}


# ----------------------------
# DBT Role
# ----------------------------
output "dbt_role_arn" {
  description = "ARN of the dbt IAM Role (if enabled)"
  value       = var.enable_dbt_role ? aws_iam_role.dbt_role[0].arn : null
}

output "dbt_ec2_instance_profile_name" {
  description = "Name of the dbt EC2 instance profile (if enabled)"
  value       = var.enable_dbt_role ? aws_iam_instance_profile.dbt_instance_profile[0].name : null
}

# ----------------------------
# Redis Role
# ----------------------------
output "redis_role_arn" {
  description = "ARN of the redis IAM Role (if enabled)"
  value       = var.enable_redis_role ? aws_iam_role.redis_role[0].arn : null
}

output "redis_ec2_instance_profile_name" {
  description = "Name of the redis EC2 instance profile (if enabled)"
  value       = var.enable_redis_role ? aws_iam_instance_profile.redis_instance_profile[0].name : null
}

# ----------------------------
# Bastion Role
# ----------------------------
output "bastion_role_arn" {
  description = "ARN of the Bastion IAM Role (if enabled)"
  value       = var.enable_bastion_role ? aws_iam_role.bastion_role[0].arn : null
}

output "bastion_ec2_instance_profile_name" {
  description = "Name of the Bastion EC2 instance profile (if enabled)"
  value       = var.enable_bastion_role ? aws_iam_instance_profile.bastion_instance_profile[0].name : null
}

# ----------------------------
# Backup Role
# ----------------------------
output "backup_role_arn" {
  description = "ARN of the Backup IAM Role (if enabled)"
  value       = var.enable_backup_role ? aws_iam_role.backup_role[0].arn : null
}

output "backup_role_name" {
  description = "Name of the Backup IAM Role (if enabled)"
  value       = var.enable_backup_role ? aws_iam_role.backup_role[0].name : null
}

# ----------------------------
# EC2 Test Instance Role
# ----------------------------
output "ec2_test_instance_role_arn" {
  description = "ARN of the EC2 test instance IAM role (if enabled)"
  value       = var.enable_ec2_test_instance_role ? aws_iam_role.ec2_test_instance_role[0].arn : null
}

# ----------------------------
# Lambda Role
# ----------------------------
output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role (if enabled)"
  value       = var.enable_lambda_role ? aws_iam_role.lambda_role[0].arn : null
}

# ----------------------------
# Elastic Beanstalk Roles
# ----------------------------
output "eb_role_arn" {
  description = "ARN of the Elastic Beanstalk service role (if enabled)"
  value       = var.enable_eb_role ? aws_iam_role.eb_role[0].arn : null
}

output "eb_instance_profile_arn" {
  description = "ARN of the Elastic Beanstalk EC2 instance profile (if enabled)"
  value       = var.enable_eb_role ? aws_iam_instance_profile.eb_instance_profile[0].arn : null
}

output "eb_codepipline_role_arn" {
  description = "ARN of the Elastic Beanstalk codepipeline role (if enabled)"
  value       = var.enable_eb_codepipeline_role ? aws_iam_role.eb_codepipeline_role[0].arn : null
}

# ----------------------------
# S3 Admin Roles
# ----------------------------

output "s3_admin_codepipeline_role_arn" {
  description = "ARN of the S3 admin service role for codepipeline  (if enabled)"
  value       = var.enable_s3_admin_codepipeline_role ? aws_iam_role.s3_admin_codepipeline_role[0].arn : null
}

output "s3_admin_codebuild_role_arn" {
  description = "ARN of the S3 admin service role for codebuild (if enabled)"
  value       = var.enable_s3_admin_codebuild_role ? aws_iam_role.s3_admin_codebuild_role[0].arn : null
}

# ----------------------------
# S3 Frontend Roles
# ----------------------------

output "s3_frontend_codepipeline_role_arn" {
  description = "ARN of the S3 frontend service role for codepipeline  (if enabled)"
  value       = var.enable_s3_frontend_codepipeline_role ? aws_iam_role.s3_frontend_codepipeline_role[0].arn : null
}

output "s3_frontend_codebuild_role_arn" {
  description = "ARN of the S3 frontend service role for codebuild (if enabled)"
  value       = var.enable_s3_frontend_codebuild_role ? aws_iam_role.s3_frontend_codebuild_role[0].arn : null
}


# ----------------------------
# Metabase EC2 Role
# ----------------------------
output "metabase_ec2_instance_profile_name" {
  description = "Name of the Metabase EC2 instance profile (if enabled)"
  value       = var.enable_metabase_role ? aws_iam_instance_profile.metabase_ec2_instance_profile[0].name : null
}

output "metabase_role_name" {
  description = "Name of the Metabase IAM role (if enabled)"
  value       = var.enable_metabase_role ? aws_iam_role.metabase_role[0].name : null
}

# ----------------------------
# Redshift Roles
# ----------------------------
output "redshift_role_arn" {
  description = "ARN of the Redshift IAM role (if enabled)"
  value       = var.enable_redshift_role ? aws_iam_role.redshift_role[0].arn : null
}

output "redshift_dms_role_arn" {
  description = "ARN of the Redshift DMS IAM role (if enabled)"
  value       = var.enable_redshift_dms_role ? aws_iam_role.redshift_dms_role[0].arn : null
}

# ----------------------------
# DMS Roles
# ----------------------------
output "dms_role_arn" {
  description = "ARN of the DMS VPC role (if enabled)"
  value       = var.enable_dms_role ? aws_iam_role.dms_role[0].arn : null
}

output "dms_cloudwatch_logs_role_arn" {
  description = "ARN of the DMS CloudWatch Logs role (if enabled)"
  value       = var.enable_dms_cw_logs_role ? aws_iam_role.dms_cloudwatch_logs[0].arn : null
}

output "dms_access_for_endpoint_role_name" {
  description = "Name of the DMS access-for-endpoint IAM role (if enabled)"
  value       = var.enable_dms_access_for_endpoint_role ? aws_iam_role.dms_access_for_endpoint[0].name : null
}

output "dms_access_for_endpoint_role_arn" {
  description = "ARN of the DMS access-for-endpoint IAM role (if enabled)"
  value       = var.enable_dms_access_for_endpoint_role ? aws_iam_role.dms_access_for_endpoint[0].arn : null
}

# output "dms_assessment_role_arn" {
#   description = "ARN of the DMS assessment IAM role (if enabled)"
#   value       = var.enable_dms_roles ? try(aws_iam_role.dms_assessment_role[0].arn, null) : null
# }

# =====================================================================
# END OF OUTPUTS
# =====================================================================
