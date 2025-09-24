# redshift parameters
data "aws_ssm_parameter" "redshift_database_name" { name = "/backend/staging-test/REDSHIFT_DATABASE" }
data "aws_ssm_parameter" "redshift_username" { name = "/backend/staging-test/REDSHIFT_USERNAME" }
data "aws_ssm_parameter" "redshift_password" { name = "/backend/staging-test/REDSHIFT_PASSWORD" }
data "aws_ssm_parameter" "redshift_port" { name = "/backend/staging-test/REDSHIFT_PORT" }

# data "aws_ssm_parameter" "redshift_snapshot_identifier"{ name = "/backend/staging-test/REDSHIFT_SNAPSHOTIDENTIFIER" }
