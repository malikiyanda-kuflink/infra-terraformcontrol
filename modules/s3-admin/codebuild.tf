# ---------- CodeBuild ----------
resource "aws_codebuild_project" "admin_build" {
  count        = var.enable_s3_admin ? 1 : 0
  name         = "${var.name_prefix}-admin-build"
  description  = "Build project for ${var.name_prefix} admin"
  service_role = var.admin_codebuild_role_arn
  tags = merge(
    {
      Name        = "${var.name_prefix}-admin-codebuild"
      Environment = var.environment
    },
    var.tags
  )

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.admin_codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "API_URL"
      value = var.api_url
    }

    environment_variable {
      name  = "APPLICATION_ENDPOINT"
      value = var.admin_website_url
    }

    environment_variable {
      name  = "ADMIN_BRANCH"
      value = var.admin_branch
    }

    environment_variable {
      name  = "NOTIFICATION_ARN"
      value = aws_sns_topic.admin_codebuild_notifications[0].arn
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.admin_buildspec_path)
  }
}

resource "aws_codebuild_project" "admin_invalidate_cache" {
  count        = var.enable_s3_admin ? 1 : 0
  name         = "${var.name_prefix}-admin-invalidate"
  description  = "Invalidate CloudFront for ${var.name_prefix} admin"
  service_role = var.admin_codebuild_role_arn
  tags = merge(
    {
      Name        = "${var.name_prefix}-admin-invalidate-cache-codebuild"
      Environment = var.environment
    },
    var.tags
  )

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = var.admin_cloudfront_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.admin_invalidate_buildspec_path)
  }
}
