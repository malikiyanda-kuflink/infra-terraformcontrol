data "aws_ssm_parameter" "admin_domain" { name = "/kuflink/${var.environment}/admin_domain" }
data "aws_ssm_parameter" "admin_bucket_name" { name = "/kuflink/${var.environment}/admin_bucket_name" }
data "aws_ssm_parameter" "admin_repo" { name = "/kuflink/${var.environment}/admin_repo" }

output "s3_admin" {
  description = "Admin S3 parameters"
  value = {
    domain      = data.aws_ssm_parameter.admin_domain.value
    bucket_name = data.aws_ssm_parameter.admin_bucket_name.value
    repo        = data.aws_ssm_parameter.admin_repo.value
  }
  sensitive = true
}