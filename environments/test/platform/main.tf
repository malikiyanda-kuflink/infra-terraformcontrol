data "aws_ssm_parameter" "aws_region" { name = "/backend/staging/AWS_REGION" }
output "aws_region" {
  value     = data.aws_ssm_parameter.aws_region.value
  sensitive = true
}