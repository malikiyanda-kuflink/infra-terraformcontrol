# staging db parameters
data "aws_ssm_parameter" "db_connection" { name = "/backend/staging/DB_CONNECTION" }
data "aws_ssm_parameter" "db_connection_read_only" { name = "/backend/staging/DB_CONNECTION_READONLY" }

data "aws_ssm_parameter" "db_database" { name = "/backend/staging/DB_DATABASE" }

data "aws_ssm_parameter" "db_host" { name = "/backend/staging/DB_HOST" }
data "aws_ssm_parameter" "db_host_readonly" { name = "/backend/staging/DB_HOST_READONLY" }

data "aws_ssm_parameter" "db_password" { name = "/backend/staging/DB_PASSWORD" }
data "aws_ssm_parameter" "db_port" { name = "/backend/staging/DB_PORT" }
data "aws_ssm_parameter" "db_username" { name = "/backend/staging/DB_USERNAME" }
