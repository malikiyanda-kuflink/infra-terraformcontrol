data "aws_caller_identity" "current" {}
resource "aws_sns_topic" "pipeline_notifications" {
  name = "codestar-notifications-Test-Backend-EB-Pipeline-Notification"
}

resource "aws_sns_topic_policy" "pipeline_notifications_policy" {
  arn = aws_sns_topic.pipeline_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "__allow_codestar_notifications",
        Effect    = "Allow",
        Principal = { Service = "codestar-notifications.amazonaws.com" },
        Action    = "SNS:Publish",
        Resource  = aws_sns_topic.pipeline_notifications.arn,
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "__allow_codepipeline_notifications",
        Effect    = "Allow",
        Principal = { Service = "codepipeline.amazonaws.com" },
        Action    = "SNS:Publish",
        Resource  = aws_sns_topic.pipeline_notifications.arn,
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "codepipeline_email_subscription" {
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol  = "email"
  endpoint  = "m.iyanda@kuflink.com"
}

resource "aws_codestarnotifications_notification_rule" "pipeline_notification" {
  name        = "Test-Backend-PHP-Build-Notification-codebuild-notification-rule"
  detail_type = "FULL"
  resource    = aws_codepipeline.kuflink_dev_ci.arn

  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-superseded"
  ]

  target {
    address = aws_sns_topic.pipeline_notifications.arn
  }
}


