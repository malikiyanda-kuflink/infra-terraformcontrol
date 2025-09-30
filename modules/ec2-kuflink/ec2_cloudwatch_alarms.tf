# 🧠 Local variable for instance name (with fallback)
locals {
  instance_name = lookup(aws_instance.kuflink_ec2.tags, "Name", "unknown-instance")
}

# 🔔 SNS Topic for Alerts
resource "aws_sns_topic" "cloudwatch_alerts" {
  name = "CloudWatchAlerts-${local.instance_name}"
}

# 📩 SNS Subscription (Email Alerts)
resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.cloudwatch_alerts.arn
  protocol  = "email"
  endpoint  = "m.iyanda@kuflink.com" # Replace with your email
}

# 🚀 1️⃣ CPU Usage Alarm (AWS EC2)
resource "aws_cloudwatch_metric_alarm" "high_cpu_usage" {
  alarm_name          = "High-CPU-${local.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "Triggers when CPU utilization exceeds 50%"

  dimensions = {
    InstanceId = aws_instance.kuflink_ec2.id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟢 2️⃣ Memory Usage Alarm
resource "aws_cloudwatch_metric_alarm" "high_memory_usage" {
  alarm_name          = "High-Memory-${local.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent-Kuflink-Wordpress-EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 65
  alarm_description   = "Triggers when memory usage exceeds 65%"

  dimensions = {
    InstanceId = aws_instance.kuflink_ec2.id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟡 3️⃣ Disk Space Alarm
resource "aws_cloudwatch_metric_alarm" "low_disk_space_alert" {
  alarm_name          = "Low-Disk-Space-${local.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent-Kuflink-Wordpress-EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 65
  alarm_description   = "Triggers when disk usage exceeds 65%"

  dimensions = {
    InstanceId = aws_instance.kuflink_ec2.id
    path       = "/"
    device     = "nvme0n1p1"
    fstype     = "ext4"
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟡 4️⃣ Swap Usage Alarm
resource "aws_cloudwatch_metric_alarm" "high_swap_usage" {
  alarm_name          = "High-Swap-Usage-${local.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "swap_used_percent"
  namespace           = "CWAgent-Kuflink-Wordpress-EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "Triggers when swap usage exceeds 50%"

  dimensions = {
    InstanceId = aws_instance.kuflink_ec2.id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟣 5️⃣ Disk I/O Alarm (High Read Operations)
resource "aws_cloudwatch_metric_alarm" "high_disk_read_ops" {
  alarm_name          = "High-Disk-ReadOps-${local.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DiskReadOps"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 1000
  alarm_description   = "Triggers when disk read operations exceed 1000 ops"

  dimensions = {
    InstanceId = aws_instance.kuflink_ec2.id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟣 6️⃣ Disk I/O Alarm (High Write Operations)
resource "aws_cloudwatch_metric_alarm" "high_disk_write_ops" {
  alarm_name          = "High-Disk-WriteOps-${local.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DiskWriteOps"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 1000
  alarm_description   = "Triggers when disk write operations exceed 1000 ops"

  dimensions = {
    InstanceId = aws_instance.kuflink_ec2.id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟠 7️⃣ Network Traffic Alarm (High Incoming Traffic)
resource "aws_cloudwatch_metric_alarm" "high_network_in" {
  alarm_name          = "High-Network-In-${local.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50000000 # 50MB
  alarm_description   = "Triggers when network incoming traffic exceeds 50MB"

  dimensions = {
    InstanceId = aws_instance.kuflink_ec2.id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🟠 8️⃣ Network Traffic Alarm (High Outgoing Traffic)
resource "aws_cloudwatch_metric_alarm" "high_network_out" {
  alarm_name          = "High-Network-Out-${local.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50000000 # 50MB
  alarm_description   = "Triggers when network outgoing traffic exceeds 50MB"

  dimensions = {
    InstanceId = aws_instance.kuflink_ec2.id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

# 🔴 9️⃣ Status Check Alarm (Instance Failure)
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "Status-Check-Failed-${local.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Triggers when EC2 instance has a failed status check"

  dimensions = {
    InstanceId = aws_instance.kuflink_ec2.id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}
