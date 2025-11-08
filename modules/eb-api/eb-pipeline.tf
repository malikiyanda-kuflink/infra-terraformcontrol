############################################
# S3 ARTIFACT BUCKET
############################################
# artifacts bucket
resource "aws_s3_bucket" "cicd_artifacts" {
  bucket        = var.artifact_bucket_name
  force_destroy = true # simple: let Terraform delete non-empty bucket
  tags          = var.artifact_bucket_tags
}



resource "aws_s3_bucket_versioning" "cicd_artifacts_versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.cicd_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}
############################################
# CODEPIPELINE
############################################
############################################
# CODEPIPELINE
############################################
resource "aws_codepipeline" "eb_pipeline" {
  name     = var.pipeline_name
  role_arn = var.codepipeline_role_arn

  # Ensure EB envs and restart Lambda exist before pipeline
  depends_on = [
    aws_elastic_beanstalk_environment.web_env,
    aws_elastic_beanstalk_environment.worker_env,
  ]

  pipeline_type  = var.pipeline_type
  execution_mode = var.execution_mode

  artifact_store {
    location = var.artifact_bucket_name
    type     = var.artifact_store_type
  }

  # ---- Source ----
  stage {
    name = var.source_stage_name

    action {
      name             = var.source_action_name
      category         = "Source"
      owner            = var.source_owner
      provider         = var.source_provider
      version          = var.source_version
      output_artifacts = [var.source_output_artifact]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.full_repository_id
        BranchName       = var.branch_name
      }
    }
  }

  # ---- Deploy to EB (Web + Worker) ----
  stage {
    name = var.deploy_stage_name

    # Web environment
    action {
      name            = var.deploy_action_name_web
      category        = "Deploy"
      owner           = var.deploy_owner
      provider        = var.deploy_provider
      version         = var.deploy_version
      input_artifacts = [var.source_output_artifact]

      configuration = {
        ApplicationName = var.eb_application_name
        EnvironmentName = var.eb_web_environment_name
      }

      run_order = 1
    }

    # Worker environment
    action {
      name            = var.deploy_action_name_worker
      category        = "Deploy"
      owner           = var.deploy_owner
      provider        = var.deploy_provider
      version         = var.deploy_version
      input_artifacts = [var.source_output_artifact]

      configuration = {
        ApplicationName = var.eb_application_name
        EnvironmentName = var.eb_worker_environment_name
      }

      run_order = 1
    }
  }
}

