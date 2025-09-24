data "aws_caller_identity" "current" {}

# ---------- SNS (notifications) ----------
resource "aws_sns_topic" "admin_codebuild_notifications" {
  count = var.enable_s3_admin ? 1 : 0
  name  = "${var.name_prefix}-admin-build-notifications"
}

resource "aws_sns_topic_subscription" "codebuild_email" {
  count     = var.enable_s3_admin ? 1 : 0
  topic_arn = aws_sns_topic.admin_codebuild_notifications[0].arn
  protocol  = "email"
  endpoint  = var.admin_codebuild_email_endpoint
}

resource "aws_sns_topic_policy" "admin_codebuild_notifications" {
  count = var.enable_s3_admin ? 1 : 0
  arn   = aws_sns_topic.admin_codebuild_notifications[0].arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowCodestarNotifications",
      Effect    = "Allow",
      Principal = { Service = "codestar-notifications.amazonaws.com" },
      Action    = "SNS:Publish",
      Resource  = aws_sns_topic.admin_codebuild_notifications[0].arn,
      Condition = { StringEquals = { "AWS:SourceAccount" = data.aws_caller_identity.current.account_id } }
    }]
  })
}

# ---------- CodeBuild notifications ----------
resource "aws_codestarnotifications_notification_rule" "admin_codebuild_rule" {
  count       = var.enable_s3_admin ? 1 : 0
  name        = "${var.name_prefix}-admin-build-notifications"
  resource    = aws_codebuild_project.admin_build[0].arn
  detail_type = "FULL"
  event_type_ids = [
    "codebuild-project-build-state-succeeded",
    "codebuild-project-build-state-failed",
    "codebuild-project-build-state-in-progress",
  ]
  target {
    address = aws_sns_topic.admin_codebuild_notifications[0].arn
  }
}

# ---------- CodePipeline notifications ----------
resource "aws_codestarnotifications_notification_rule" "admin_s3_pipeline_rule" {
  count       = var.enable_s3_admin ? 1 : 0
  name        = "${var.name_prefix}-admin-pipeline-notifications"
  resource    = aws_codepipeline.admin_pipeline[0].arn
  detail_type = "FULL"

  # Common, high-signal events
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-superseded",

    # (Optional)more granular stage/action events:
    # "codepipeline-pipeline-stage-execution-started",
    # "codepipeline-pipeline-stage-execution-succeeded",
    # "codepipeline-pipeline-stage-execution-failed",
    # "codepipeline-pipeline-action-execution-started",
    # "codepipeline-pipeline-action-execution-succeeded",
    # "codepipeline-pipeline-action-execution-failed",
  ]

  target {
    address = aws_sns_topic.admin_codebuild_notifications[0].arn # re-use same topic
  }
}
