
data "aws_ssm_parameter" "staging_dms_role_arn" { name = "/staging/dms_role_arn" }
data "aws_ssm_parameter" "staging_dms_endpoint_access_arn" { name = "/staging/dms_access_for_endpoint_arn" }
data "aws_ssm_parameter" "staging_dms_logs_role_arn" { name = "/staging/dms_cloudwatch_logs_role_arn" }