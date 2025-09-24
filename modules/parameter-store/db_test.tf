# test db parameters 
data "aws_ssm_parameter" "db_test_connection" { name = "/backend/staging-test/DB_CONNECTION" }
data "aws_ssm_parameter" "db_test_connection_readonly" { name = "/backend/staging-test/DB_CONNECTION_READONLY" }


data "aws_ssm_parameter" "db_test_database" { name = "/backend/staging-test/DB_DATABASE" }

data "aws_ssm_parameter" "db_test_host" { name = "/backend/staging-test/DB_HOST" }
data "aws_ssm_parameter" "db_test_host_readonly" { name = "/backend/staging-test/DB_HOST_READONLY" }


data "aws_ssm_parameter" "db_test_password" { name = "/backend/staging-test/DB_PASSWORD" }
data "aws_ssm_parameter" "db_test_port" { name = "/backend/staging-test/DB_PORT" }
data "aws_ssm_parameter" "db_test_username" { name = "/backend/staging-test/DB_USERNAME" }





