data "aws_caller_identity" "current" {}

# -------- EB Deployments topic (optional) --------
resource "aws_sns_topic" "eb_deployments" {
  count = var.create_eb_topic ? 1 : 0
  name  = var.eb_topic_name
  tags  = var.tags
}

resource "aws_sns_topic_subscription" "eb_email_subs" {
  for_each  = var.create_eb_topic ? toset(var.eb_notification_emails) : []
  topic_arn = aws_sns_topic.eb_deployments[0].arn
  protocol  = var.eb_notification_protocol
  endpoint  = each.value
}

# -------- Pipeline notifications topic (optional) --------
resource "aws_sns_topic" "pipeline_notifications" {
  count = var.create_pipeline_topic ? 1 : 0
  name  = var.pipeline_topic_name
  tags  = var.tags
}

resource "aws_sns_topic_policy" "pipeline_notifications_policy" {
  count = var.create_pipeline_topic ? 1 : 0
  arn   = aws_sns_topic.pipeline_notifications[0].arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "__allow_codestar_notifications",
        Effect    = "Allow",
        Principal = { Service = "codestar-notifications.amazonaws.com" },
        Action    = "SNS:Publish",
        Resource  = aws_sns_topic.pipeline_notifications[0].arn,
        Condition = {
          StringEquals = { "AWS:SourceAccount" = data.aws_caller_identity.current.account_id }
        }
      },
      {
        Sid       = "__allow_codepipeline_notifications",
        Effect    = "Allow",
        Principal = { Service = "codepipeline.amazonaws.com" },
        Action    = "SNS:Publish",
        Resource  = aws_sns_topic.pipeline_notifications[0].arn,
        Condition = {
          StringEquals = { "AWS:SourceAccount" = data.aws_caller_identity.current.account_id }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "pipeline_email_subs" {
  for_each  = var.create_pipeline_topic ? toset(var.pipeline_notification_emails) : []
  topic_arn = aws_sns_topic.pipeline_notifications[0].arn
  protocol  = "email"
  endpoint  = each.value
}

# -------- CodeStar Notifications rule (optional) --------
resource "aws_codestarnotifications_notification_rule" "pipeline_notification" {
  count       = var.create_pipeline_notification_rule ? 1 : 0
  name        = var.pipeline_notification_rule_name
  detail_type = "FULL"
  resource    = var.pipeline_arn

  event_type_ids = var.pipeline_notification_event_type_ids

  target {
    address = aws_sns_topic.pipeline_notifications[0].arn
  }
}
