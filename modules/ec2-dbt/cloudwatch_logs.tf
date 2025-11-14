# System Logs
resource "aws_cloudwatch_log_group" "dbt_syslog" {
  name              = "/ec2/${var.dbt_name}/syslog"
  retention_in_days = 7

  tags = merge(
    { Name = "${var.name_prefix}-dbt-syslog" },
    var.instance_tags
  )
}

resource "aws_cloudwatch_log_group" "dbt_kernel" {
  name              = "/ec2/${var.dbt_name}/kern"
  retention_in_days = 7

  tags = merge(
    { Name = "${var.name_prefix}-dbt-kernel" },
    var.instance_tags
  )
}

resource "aws_cloudwatch_log_group" "dbt_auth" {
  name              = "/ec2/${var.dbt_name}/auth"
  retention_in_days = 30

  tags = merge(
    { Name = "${var.name_prefix}-dbt-auth" },
    var.instance_tags
  )
}

# Bootstrap Logs
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

# DBT Application Logs
resource "aws_cloudwatch_log_group" "dbt_runtime" {
  name              = "/ec2/${var.dbt_name}/dbt-runtime"
  retention_in_days = 7

  tags = merge(
    { Name = "${var.name_prefix}-dbt-runtime" },
    var.instance_tags
  )
}

resource "aws_cloudwatch_log_group" "dbt_scheduled_runs" {
  name              = "/ec2/${var.dbt_name}/dbt-scheduled-runs"
  retention_in_days = 30

  tags = merge(
    { Name = "${var.name_prefix}-dbt-scheduled-runs" },
    var.instance_tags
  )
}

resource "aws_cloudwatch_log_group" "dbt_cron" {
  name              = "/ec2/${var.dbt_name}/dbt-cron"
  retention_in_days = 7

  tags = merge(
    { Name = "${var.name_prefix}-dbt-cron" },
    var.instance_tags
  )
}