# ---------- CodeBuild ----------
resource "aws_codebuild_project" "frontend_build" {
  count        = var.enable_s3_frontend ? 1 : 0
  name         = "${var.name_prefix}-frontend-build"
  description  = "Build project for ${var.name_prefix} frontend"
  service_role = var.frontend_codebuild_role_arn
  tags = merge(
    {
      Name        = "${var.name_prefix}-codebuild"
      Environment = var.environment
    },
    var.tags
  )

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.frontend_codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "ANGULAR_CONFIGURATION"
      value = "qa"
    }

    environment_variable {
      name  = "HUSKY"
      value = "0"
    } # disable git hooks in CI (avoids husky error)


    environment_variable {
      name  = "API_URL"
      value = var.api_url
    }

    environment_variable {
      name  = "FRONTEND_BRANCH"
      value = var.frontend_branch
    }
    environment_variable {
      name  = "APPLICATION_ENDPOINT"
      value = var.frontend_app_bucket
    }

    environment_variable {
      name  = "NOTIFICATION_ARN"
      value = aws_sns_topic.codebuild_notifications[0].arn
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.frontend_buildspec_path)
  }
}

resource "aws_codebuild_project" "frontend_invalidate_cache" {
  count        = var.enable_s3_frontend ? 1 : 0
  name         = "${var.name_prefix}-frontend-invalidate"
  description  = "Invalidate CloudFront for ${var.name_prefix} frontend"
  service_role = var.frontend_codebuild_role_arn
  tags = merge(
    {
      Name        = "${var.name_prefix}-codebuild"
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
      value = var.frontend_cloudfront_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.frontend_invalidate_buildspec_path)
  }
}