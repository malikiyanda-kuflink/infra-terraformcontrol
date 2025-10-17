# ===================================================================
# FRONTEND S3 PARAMETERS
# ===================================================================
data "aws_ssm_parameter" "frontend_domain" { name = "/kuflink/${var.environment}/frontend_domain" }
data "aws_ssm_parameter" "maintenance_bucket_name" { name = "/kuflink/${var.environment}/maintenance_bucket_name" }
data "aws_ssm_parameter" "frontend_bucket_name" { name = "/kuflink/${var.environment}/frontend_bucket_name" }
data "aws_ssm_parameter" "frontend_repo" { name = "/kuflink/${var.environment}/frontend_repo" }

output "s3_frontend" {
  description = "Frontend S3 parameters from s3_frontend.tf"
  value = {
    domain                  = data.aws_ssm_parameter.frontend_domain.value
    maintenance_bucket_name = data.aws_ssm_parameter.maintenance_bucket_name.value
    bucket_name             = data.aws_ssm_parameter.frontend_bucket_name.value
    repo                    = data.aws_ssm_parameter.frontend_repo.value
  }
  sensitive = true
}