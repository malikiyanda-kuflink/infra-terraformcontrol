# ✅ 1️⃣ Replica Lag Too High
resource "aws_cloudwatch_metric_alarm" "replica_lag_too_high" {
  count = var.create_read_replica ? 1 : 0
  alarm_name          = "${local.replica_instance_name}-ReplicaLag-Too-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 300  # 5 minutes lag
  alarm_description   = "Triggers if replication lag exceeds 300 seconds"

  dimensions = {
    DBInstanceIdentifier = local.replica_instance_id
  }

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}

# ✅ 2️⃣ Replica Sync Broken (Optional - Persistent Lag)
resource "aws_cloudwatch_metric_alarm" "replica_sync_broken" {
  count = var.create_read_replica ? 1 : 0
  alarm_name          = "${local.replica_instance_name}-ReplicaSync-Broken"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 4
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 60
  alarm_description   = "Triggers if replication lag persists above 60 seconds for 20 minutes"

  dimensions = {
    DBInstanceIdentifier = local.replica_instance_id
  }

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}

# ✅ 3️⃣ Write Activity Detected on Replica (Optional)
resource "aws_cloudwatch_metric_alarm" "replica_write_activity" {
  count = var.create_read_replica ? 1 : 0
  alarm_name          = "${local.replica_instance_name}-Write-Detected"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Sum"
  threshold           = 50  # Adjusted from 0 to 50
  alarm_description   = "Triggers if WriteIOPS exceeds normal replication level on replica"

  dimensions = {
    DBInstanceIdentifier = local.replica_instance_id
  }

  treat_missing_data = "notBreaching"  # Optional but recommended

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}


# ✅ 4️⃣ High DB Connections on Replica (Optional)
resource "aws_cloudwatch_metric_alarm" "replica_high_connections" {
  count = var.create_read_replica ? 1 : 0
  alarm_name          = "${local.replica_instance_name}-High-Connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80  # Adjust based on expected connection count
  alarm_description   = "Triggers if the number of DB connections on the read replica is high"

  dimensions = {
    DBInstanceIdentifier = local.replica_instance_id
  }

  alarm_actions = [aws_sns_topic.rds_cloudwatch_alerts.arn]
}
