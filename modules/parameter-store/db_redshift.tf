# ===================================================================
# REDSHIFT DATABASE PARAMETERS
# ===================================================================
data "aws_ssm_parameter" "redshift_database_name" { name = "/backend/${var.environment}/REDSHIFT_DATABASE" }
data "aws_ssm_parameter" "redshift_username" { name = "/backend/${var.environment}/REDSHIFT_USERNAME" }
data "aws_ssm_parameter" "redshift_password" { name = "/backend/${var.environment}/REDSHIFT_PASSWORD" }
data "aws_ssm_parameter" "redshift_port" { name = "/backend/${var.environment}/REDSHIFT_PORT" }

output "db_redshift" {
  description = "Redshift database parameters from db_redshift.tf"
  value = {
    database_name = data.aws_ssm_parameter.redshift_database_name.value
    username      = data.aws_ssm_parameter.redshift_username.value
    password      = data.aws_ssm_parameter.redshift_password.value
    port          = data.aws_ssm_parameter.redshift_port.value
  }
  sensitive = true
}