# 🔔 SNS Topic for RDS Alerts
resource "aws_sns_topic" "rds_cloudwatch_alerts" {
  name = "RDSCloudWatchAlerts-${local.db_instance_name}"
}

# 📩 Email Subscription
resource "aws_sns_topic_subscription" "rds_email_notification" {
  topic_arn = aws_sns_topic.rds_cloudwatch_alerts.arn
  protocol  = "email"
  endpoint  = "m.iyanda@kuflink.com" # Replace if needed
}

# 🟥 1️⃣ High CPU Usage
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "${local.db_instance_name}-High-CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggers when RDS CPU utilization exceeds 80%"

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}

# 🟦 2️⃣ Low Freeable Memory
resource "aws_cloudwatch_metric_alarm" "rds_low_memory" {
  alarm_name          = "${local.db_instance_name}-Low-Memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 200000000 # ~200MB
  alarm_description   = "Triggers when freeable memory is critically low"

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}

# 🟨 3️⃣ Low Free Storage Space
resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${local.db_instance_name}-Low-Storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10000000000 # 10 GB
  alarm_description   = "Triggers when available storage space drops below 10GB"

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}

# 🟠 4️⃣ High Disk Queue Depth
resource "aws_cloudwatch_metric_alarm" "rds_high_disk_queue" {
  alarm_name          = "${local.db_instance_name}-High-DiskQueueDepth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 64
  alarm_description   = "Triggers when disk queue depth exceeds 64"

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}

# 🟣 5️⃣ High DB Connections
resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  alarm_name          = "${local.db_instance_name}-High-Connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggers when RDS database connections are high"

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}

# 🔴 6️⃣ RDS Instance Status Check (Availability)
resource "aws_cloudwatch_metric_alarm" "rds_zero_connections_detected" {
  alarm_name          = "${local.db_instance_name}-Zero-Connections"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Triggers if DB reports fewer than 1 connection (likely down)"

  dimensions = {
    DBInstanceIdentifier = local.db_instance_id
  }

  treat_missing_data = "breaching"

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}
