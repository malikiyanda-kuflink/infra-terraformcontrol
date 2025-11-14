# Pass existing CloudWatch SNS topic ARN to user-data via SSM
resource "aws_ssm_parameter" "dbt_sns_topic" {
  name  = "/ec2/dbt/${var.environment}/sns_topic_arn"
  type  = "String"
  value = aws_sns_topic.cloudwatch_alerts.arn # Use existing topic
}