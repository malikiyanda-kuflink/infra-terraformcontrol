  locals {
    restart_eb_lambda_source_dir = "${path.module}/lambda_functions/restart-eb-instances"
  }

  data "archive_file" "restart_eb_instances_zip" {
    type        = "zip"
    source_dir  = local.restart_eb_lambda_source_dir
    output_path = "${path.module}/build/restart-eb-instances.zip"
  }

  resource "aws_iam_role" "restart_eb_instances_role" {
    name = "kuflink-test-restart-eb-instances-role"

    assume_role_policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }]
    })
  }

  resource "aws_iam_policy" "restart_eb_instances_policy" {
    name        = "${var.lambda_restart_eb_instances_policy_name}"
    description = "Allow Lambda to describe EB environment resources and reboot EC2 instances"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          # Discover EB resources → CFN → ASG → EC2
          Effect = "Allow",
          Action = [
            "elasticbeanstalk:DescribeEnvironmentResources",
            "elasticbeanstalk:DescribeEnvironments",
            "cloudformation:DescribeStacks",
            "cloudformation:DescribeStackResources",
            "autoscaling:DescribeAutoScalingGroups",
            "ec2:DescribeInstances",
            "iam:ListRolePolicies"
          ],
          Resource = "*"
        },
        {
          # Actually reboot the EB instances
          Effect = "Allow",
          Action = [
            "ec2:RebootInstances"
          ],
          Resource = "*"
        },
        {
          Effect = "Allow",
          Action = [
            "codepipeline:PutJobSuccessResult",
            "codepipeline:PutJobFailureResult"
          ],
          Resource = "*"
        },
        {
          # Lambda logs
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource = "*"
        }
      ]
    })
  }


  resource "aws_iam_role_policy_attachment" "restart_eb_instances_attach" {
    role       = aws_iam_role.restart_eb_instances_role.name
    policy_arn = aws_iam_policy.restart_eb_instances_policy.arn
  }

  resource "aws_lambda_function" "restart_eb_instances" {
    function_name = "restart-eb-instances"
    role          = aws_iam_role.restart_eb_instances_role.arn
    runtime       = "python3.12"
    handler       = "lambda_function.lambda_handler"

    filename         = data.archive_file.restart_eb_instances_zip.output_path
    source_code_hash = data.archive_file.restart_eb_instances_zip.output_base64sha256

    environment {
      variables = {
        EB_ENV_WEB_NAME    = var.eb_web_environment_name
        EB_ENV_WORKER_NAME = var.enable_worker_deploy ? var.eb_worker_environment_name : ""
      }
    }

    timeout = 60
  }
