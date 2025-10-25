# ============================================================================
# AWS CodeDeploy Terraform Configuration
# ============================================================================
# This file sets up AWS CodeDeploy for automated application deployments
# to EC2 instances. CodeDeploy manages the deployment lifecycle including
# health checks, rollbacks, and deployment strategies.
# ============================================================================

# ----------------------------------------------------------------------------
# S3 Bucket for CodeDeploy Artifacts
# ----------------------------------------------------------------------------
# CodeDeploy requires application revisions to be stored in S3.
# GitHub Actions will upload your application bundle here, and CodeDeploy
# will pull from this bucket to deploy to EC2 instances.
# ----------------------------------------------------------------------------
resource "aws_s3_bucket" "codedeploy_bucket" {
  bucket        = "${var.name_prefix}-codedeploy-artifacts"
  force_destroy = true

  tags = {
    Name    = "${var.code_deploy_project_name}-codedeploy-bucket"
    Purpose = "CodeDeploy application artifacts storage"
  }
}

# Enable versioning to track deployment artifact history
resource "aws_s3_bucket_versioning" "codedeploy_bucket" {
  bucket = aws_s3_bucket.codedeploy_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle policy to automatically delete old artifacts (cost optimization)
resource "aws_s3_bucket_lifecycle_configuration" "codedeploy_bucket" {
  bucket = aws_s3_bucket.codedeploy_bucket.id

  rule {
    id     = "delete-old-artifacts"
    status = "Enabled"

    # Add this empty filter block to apply rule to all objects
    filter {}

    expiration {
      days = 30 # Keep artifacts for 30 days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7 # Keep old versions for 7 days
    }
  }
}

# Block public access - security best practice
resource "aws_s3_bucket_public_access_block" "codedeploy_bucket" {
  bucket = aws_s3_bucket.codedeploy_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ----------------------------------------------------------------------------
# CodeDeploy Application
# ----------------------------------------------------------------------------
# A CodeDeploy Application is a container for deployment groups and revisions.
# Think of it as your project's deployment namespace.
# ----------------------------------------------------------------------------
resource "aws_codedeploy_app" "app" {
  name             = var.code_deploy_project_name
  compute_platform = "Server" # Options: Server, Lambda, ECS

  tags = {
    Name = "${var.code_deploy_project_name}-codedeploy-app"
  }
}

# ----------------------------------------------------------------------------
# CodeDeploy Deployment Group
# ----------------------------------------------------------------------------
# A deployment group defines:
# - Which EC2 instances to deploy to (via tags)
# - How to deploy (all at once, rolling, blue/green)
# - When to consider deployment successful
# - Automatic rollback conditions
# ----------------------------------------------------------------------------
resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "${var.code_deploy_project_name}-DG"
  service_role_arn       = var.codedeploy_service_role_arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce" # All instances at once

  # Target EC2 instances using tags
  ec2_tag_set {
    ec2_tag_filter {
      type  = "KEY_AND_VALUE"
      key   = "DBT-Test-DeploymentTarget"
      value = var.code_deploy_project_name
    }
  }

  # Automatic rollback configuration
  # Rolls back if deployment fails or CloudWatch alarms trigger
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  # Deployment style configuration
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL" # In-place deployment
    deployment_type   = "IN_PLACE"
  }

  tags = {
    Name = "${var.code_deploy_project_name}-deployment-group"
  }
}

# ----------------------------------------------------------------------------
# SNS Topic for Deployment Notifications (Optional)
# ----------------------------------------------------------------------------
# Receive notifications about deployment status via email or other endpoints
# ----------------------------------------------------------------------------
resource "aws_sns_topic" "codedeploy_notifications" {
  name = "${var.code_deploy_project_name}-codedeploy-notifications"

  tags = {
    Name = "${var.code_deploy_project_name}-codedeploy-notifications"
  }
}

# Subscribe your email to receive notifications
resource "aws_sns_topic_subscription" "codedeploy_email" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.codedeploy_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

