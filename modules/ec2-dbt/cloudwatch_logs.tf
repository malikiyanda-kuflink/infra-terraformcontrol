# In your ec2-dbt module or apps layer
resource "aws_cloudwatch_log_group" "dbt_syslog" {
  name              = "/ec2/${var.dbt_name}/syslog"
  retention_in_days = 7

  tags = merge(
    { Name = "${var.name_prefix}-dbt-syslog" },
    var.instance_tags
  )
}

resource "aws_cloudwatch_log_group" "dbt_cloud_init" {
  name              = "/ec2/${var.dbt_name}/cloud-init"
  retention_in_days = 7

  tags = merge(
    { Name = "${var.name_prefix}-dbt-cloud-init" },
    var.instance_tags
  )
}

resource "aws_cloudwatch_log_group" "dbt_user_data" {
  name              = "/ec2/${var.dbt_name}/user-data"
  retention_in_days = 7

  tags = merge(
    { Name = "${var.name_prefix}-dbt-user-data" },
    var.instance_tags
  )
}

#################################################################
#DBT SPECIFIC LOGS-
# dbt.log is very chatty, long-lived, good for debugging.
# run_results.json is more “job event / status”, and you might later create metric filters / alarms off failures.

#################################################################

resource "aws_cloudwatch_log_group" "dbt_runtime" {
  name              = "/ec2/${var.dbt_name}/dbt-runtime"
  retention_in_days = 7

  tags = merge(
    { Name = "${var.name_prefix}-dbt-runtime" },
    var.instance_tags
  )
}

# resource "aws_cloudwatch_log_group" "dbt_run_results" {
#   name              = "/ec2/${var.dbt_name}/dbt-run-results"
#   retention_in_days = 7

#   tags = merge(
#     { Name = "${var.name_prefix}-dbt-run-results" },
#     var.instance_tags
#   )
# }