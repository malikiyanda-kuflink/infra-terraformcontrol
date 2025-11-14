# Metric filter for DBT run failures
resource "aws_cloudwatch_log_metric_filter" "dbt_run_failed" {
  name           = "${var.dbt_name}-DBT-Run-Failed"
  log_group_name = aws_cloudwatch_log_group.dbt_scheduled_runs.name
  pattern        = "❌ DBT run failed"

  metric_transformation {
    name          = "DBTRunFailures"
    namespace     = "DBT/Runs"
    value         = "1"
    default_value = 0
  }
}

# Alarm for DBT failures
resource "aws_cloudwatch_metric_alarm" "dbt_run_failures" {
  alarm_name          = "${var.dbt_name}-DBT-Run-Failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DBTRunFailures"
  namespace           = "DBT/Runs"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert when DBT scheduled run fails"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}