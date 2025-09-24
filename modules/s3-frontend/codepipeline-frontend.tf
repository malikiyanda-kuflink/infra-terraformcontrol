# ----------------------------------------
# Pipeline artifact bucket (same region)
# ----------------------------------------
resource "aws_s3_bucket" "frontend_artifacts" {
  count         = var.enable_s3_frontend ? 1 : 0
  bucket        = var.frontend_artifact_bucket
  force_destroy = true

  tags = merge(
    { Name = "${var.name_prefix}-frontend-artifacts", Environment = var.environment },
    var.tags
  )
}

resource "aws_s3_bucket_public_access_block" "frontend_artifacts" {
  count                   = var.enable_s3_frontend ? 1 : 0
  bucket                  = aws_s3_bucket.frontend_artifacts[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "frontend_artifacts" {
  count  = var.enable_s3_frontend ? 1 : 0
  bucket = aws_s3_bucket.frontend_artifacts[0].id
  versioning_configuration {
    status = "Enabled"
  }
}


# ---------- CodePipeline ----------
resource "aws_codepipeline" "frontend_pipeline" {
  count          = var.enable_s3_frontend ? 1 : 0
  name           = "${var.name_prefix}-frontend-pipeline"
  role_arn       = var.frontend_codepipeline_role_arn
  pipeline_type  = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    location = aws_s3_bucket.frontend_artifacts[0].bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.frontend_codestar_connection
        FullRepositoryId = var.frontend_repo
        BranchName       = var.frontend_branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.frontend_build[0].name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "DeployToS3"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        BucketName = var.frontend_app_bucket
        Extract    = "true"
      }
    }
  }

  stage {
    name = "InvalidateCache"
    action {
      name            = "InvalidateCloudFront"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        ProjectName = aws_codebuild_project.frontend_invalidate_cache[0].name
      }
    }
  }
}


