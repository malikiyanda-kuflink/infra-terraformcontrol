data "aws_ssm_parameter" "aws_region" { name = "/kuflink/${environment}/aws_region" }
output "aws_region" {
  value     = data.aws_ssm_parameter.aws_region.value
  sensitive = true
}