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