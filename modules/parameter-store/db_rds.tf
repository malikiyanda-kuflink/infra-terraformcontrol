# ===================================================================
# RDS DATABASE PARAMETERS
# ===================================================================
data "aws_ssm_parameter" "db_connection" { name = "/backend/${var.environment}/DB_CONNECTION" }
data "aws_ssm_parameter" "db_connection_readonly" { name = "/backend/${var.environment}/DB_CONNECTION_READONLY" }
data "aws_ssm_parameter" "db_database" { name = "/backend/${var.environment}/DB_DATABASE" }
data "aws_ssm_parameter" "db_host" { name = "/backend/${var.environment}/DB_HOST" }
data "aws_ssm_parameter" "db_host_readonly" { name = "/backend/${var.environment}/DB_HOST_READONLY" }
data "aws_ssm_parameter" "db_password" { name = "/backend/${var.environment}/DB_PASSWORD" }
data "aws_ssm_parameter" "db_port" { name = "/backend/${var.environment}/DB_PORT" }
data "aws_ssm_parameter" "db_username" { name = "/backend/${var.environment}/DB_USERNAME" }

output "db_rds" {
  description = "RDS database parameters from db_rds.tf"
  value = {
    connection          = data.aws_ssm_parameter.db_connection.value
    connection_readonly = data.aws_ssm_parameter.db_connection_readonly.value
    database            = data.aws_ssm_parameter.db_database.value
    host                = data.aws_ssm_parameter.db_host.value
    host_readonly       = data.aws_ssm_parameter.db_host_readonly.value
    password            = data.aws_ssm_parameter.db_password.value
    port                = data.aws_ssm_parameter.db_port.value
    username            = data.aws_ssm_parameter.db_username.value
  }
  sensitive = true
}