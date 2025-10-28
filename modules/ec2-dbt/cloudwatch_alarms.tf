# 🔔 SNS Topic for Alerts
resource "aws_sns_topic" "cloudwatch_alerts" {
  name = "CloudWatchAlerts-${local.instance_name}"
}

# 📩 SNS Subscription (Email Alerts)
resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.cloudwatch_alerts.arn
  protocol  = "email"
  endpoint  = var.cloudwatch_ops_notification_email
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

resource "aws_cloudwatch_log_group" "dbt_run_results" {
  name              = "/ec2/${var.dbt_name}/dbt-run-results"
  retention_in_days = 7

  tags = merge(
    { Name = "${var.name_prefix}-dbt-run-results" },
    var.instance_tags
  )
}

#################################################################

# 🚀 1️⃣ CPU Usage Alarm (AWS EC2)
resource "aws_cloudwatch_metric_alarm" "high_cpu_usage" {
  alarm_name          = "${local.instance_name}-High-CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "Triggers when CPU utilization exceeds 50%"

  dimensions = {
    InstanceId = local.instance_id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟢 2️⃣ Memory Usage Alarm
resource "aws_cloudwatch_metric_alarm" "high_memory_usage" {
  alarm_name          = "${local.instance_name}-High-Memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = local.cwagent_namespace
  period              = 60
  statistic           = "Average"
  threshold           = 65
  alarm_description   = "Triggers when memory usage exceeds 65%"

  dimensions = {
    InstanceId = local.instance_id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟡 3️⃣ Disk Space Alarm
resource "aws_cloudwatch_metric_alarm" "low_disk_space_alert" {
  alarm_name          = "${local.instance_name}-Low-Disk-Space"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "disk_used_percent"
  namespace           = local.cwagent_namespace
  period              = 60
  statistic           = "Average"
  threshold           = 65
  alarm_description   = "Triggers when disk usage exceeds 65%"

  dimensions = {
    InstanceId = local.instance_id
    path       = local.disk_path
    device     = local.disk_device
    fstype     = local.disk_fstype
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}


# 🟠 7️⃣ Network Traffic Alarm (High Incoming Traffic)
resource "aws_cloudwatch_metric_alarm" "high_network_in" {
  alarm_name          = "${local.instance_name}-High-Network-In"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50000000 # 50MB
  alarm_description   = "Triggers when network incoming traffic exceeds 50MB"

  dimensions = {
    InstanceId = local.instance_id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟠 8️⃣ Network Traffic Alarm (High Outgoing Traffic)
resource "aws_cloudwatch_metric_alarm" "high_network_out" {
  alarm_name          = "${local.instance_name}-High-Network-Out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50000000 # 50MB
  alarm_description   = "Triggers when network outgoing traffic exceeds 50MB"

  dimensions = {
    InstanceId = local.instance_id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🔴 9️⃣ Status Check Alarm (Instance Failure)
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "${local.instance_name}-Status-Check-Failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Triggers when EC2 instance has a failed status check"

  dimensions = {
    InstanceId = local.instance_id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}


# # 🟡 4️⃣ Swap Usage Alarm
# resource "aws_cloudwatch_metric_alarm" "high_swap_usage" {
#   alarm_name          = "${local.instance_name}-High-Swap-Usage"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "swap_used_percent"
#   namespace           = local.cwagent_namespace
#   period              = 60
#   statistic           = "Average"
#   threshold           = 50
#   alarm_description   = "Triggers when swap usage exceeds 50%"

#   dimensions = {
#     InstanceId = local.instance_id
#   }

#   alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
# }

# # 🟣 5️⃣ Disk I/O Alarm (High Read Operations)
# resource "aws_cloudwatch_metric_alarm" "high_disk_read_ops" {
#   alarm_name          = "${local.instance_name}-High-Disk-ReadOps"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "DiskReadOps"
#   namespace           = "AWS/EC2"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 1000
#   alarm_description   = "Triggers when disk read operations exceed 1000 ops"

#   dimensions = {
#     InstanceId = local.instance_id
#   }

#   alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
# }

# # 🟣 6️⃣ Disk I/O Alarm (High Write Operations)
# resource "aws_cloudwatch_metric_alarm" "high_disk_write_ops" {
#   alarm_name          = "${local.instance_name}-High-Disk-WriteOps"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "DiskWriteOps"
#   namespace           = "AWS/EC2"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 1000
#   alarm_description   = "Triggers when disk write operations exceed 1000 ops"

#   dimensions = {
#     InstanceId = local.instance_id
#   }

#   alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
# }