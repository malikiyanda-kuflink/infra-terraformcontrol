variable "name_prefix" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

variable "codedeploy_service_role_name" { type = string }
variable "dbt_role_name" { type = string }
variable "backup_role_name" { type = string }
variable "redis_role_name" { type = string }
variable "bastion_role_name" { type = string }
variable "ec2_test_instance_role_name" { type = string }
variable "lambda_role_name" { type = string }
variable "eb_role_name" { type = string }
variable "eb_codepipeline_role_name" { type = string }
variable "s3_frontend_codepipeline_role_name" { type = string }
variable "s3_frontend_codebuild_role_name" { type = string }
variable "eb_instance_profile_name" { type = string }
variable "metabase_role_name" { type = string }
variable "redshift_role_name" { type = string }
variable "redshift_endpoint_role_name" { type = string }
variable "s3_admin_codebuild_role_name" { type = string }
variable "s3_admin_codepipeline_role_name" { type = string }
variable "rds_enhanced_monitoring_role_name" { type = string }

variable "dms_role_name" {
  type    = string
  default = "dms-vpc-role"
}

variable "dms_cloudwatch_logs_role_name" {
  type    = string
  default = "dms-cloudwatch-logs-role"
}
variable "dms_access_for_endpoint_role_name" {
  type    = string
  default = "dms-access-for-endpoint"
}


variable "enable_codedeploy_service_role" { type = string }
variable "enable_dbt_role" { type = bool }
variable "enable_backup_role" { type = bool }
variable "enable_redis_role" { type = bool }
variable "enable_bastion_role" { type = bool }
variable "enable_ec2_test_instance_role" { type = bool }
variable "enable_lambda_role" { type = bool }
variable "enable_eb_role" { type = bool }
variable "enable_eb_codepipeline_role" { type = bool }
variable "enable_s3_frontend_codepipeline_role" { type = bool }
variable "enable_s3_frontend_codebuild_role" { type = bool }
variable "enable_s3_admin_codepipeline_role" { type = bool }
variable "enable_s3_admin_codebuild_role" { type = bool }

variable "enable_metabase_role" { type = bool }
variable "enable_redshift_role" { type = bool }
variable "enable_redshift_dms_role" { type = bool }
# variable "enable_dms_assessment_roles" { type = bool  }
variable "enable_dms_role" { type = bool }
variable "enable_dms_cw_logs_role" { type = bool }
variable "enable_dms_access_for_endpoint_role" { type = bool }
variable "enable_rds_enhanced_monitoring_role" { type = bool }

