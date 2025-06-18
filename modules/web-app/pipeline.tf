resource "aws_codepipeline" "kuflink_dev_ci" {
  name     = "Test-Kuflink-dev-CI"
  role_arn = aws_iam_role.codepipeline_role.arn

  pipeline_type  = "V2"     # Explicitly define this as a V2 pipeline
  execution_mode = "QUEUED" # Allows multiple executions to run in parallel
  # execution_mode = "PARALLEL"  # Allows multiple executions to run in parallel

  artifact_store {
    location = aws_s3_bucket.cicd_artifacts.bucket
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
        ConnectionArn    = var.kuflink_codestar_connection
        FullRepositoryId = "kuflink/kuflink-api"
        BranchName       = "staging-test"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.kuflink_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.kuflink_env.name
      }
    }

    action {
      name            = "DeployWorker"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.kuflink_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.worker-env.name
      }
    }
  }

}
