# ----------------------------
# Maintenance Pipeline
# ----------------------------
resource "aws_codepipeline" "maintenance_pipeline" {
  count          = var.enable_s3_frontend ? 1 : 0
  name           = var.maintenance_pipeline_name
  role_arn       = var.frontend_codepipeline_role_arn
  pipeline_type  = "V2"
  execution_mode = "QUEUED"
  tags           = var.tags

  artifact_store {
    location = var.frontend_artifact_bucket
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
        BranchName       = var.maintenance_branch
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
      name            = "DeployMaintenanceToS3"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        BucketName = aws_s3_bucket.maintenance[0].bucket
        Extract    = "true"
      }
    }
  }
}