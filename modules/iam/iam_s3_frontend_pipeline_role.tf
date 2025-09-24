############################################
# VARIABLES
############################################
variable "s3_frontend_codepipeline_managed_policy_arns" {
  type        = list(string)
  description = "Managed policies to attach to the CodePipeline role"
  # Add/override at the layer if needed.
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    # "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
    # "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    # "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    # "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  ]
}

############################################
# ROLE
############################################
resource "aws_iam_role" "s3_frontend_codepipeline_role" {
  count = var.enable_s3_frontend_codepipeline_role ? 1 : 0
  name  = var.s3_frontend_codepipeline_role_name
  tags  = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "",
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

############################################
# ATTACH AWS-MANAGED POLICIES
############################################
resource "aws_iam_role_policy_attachment" "s3_frontend_codepipeline_managed" {
  for_each   = toset(var.s3_frontend_codepipeline_managed_policy_arns)
  role       = aws_iam_role.s3_frontend_codepipeline_role[0].name
  policy_arn = each.value
}

############################################
# ONE CUSTOM "EXTRAS" POLICY (LEFTOVERS)
############################################
# - codestar-connections:UseConnection (scoped or *)
# - iam:PassRole (scoped list or *)
# - EB API calls used during deploy
# - CloudFormation READ (scoped to EB stacks) to satisfy GetTemplate, Describe*, etc.
resource "aws_iam_policy" "s3_frontend_codepipeline_codepipeline_extras" {
  name        = "${var.name_prefix}-s3-frontend-codepipeline_extras"
  description = "extras for CodePipeline (CodeStar, PassRole, CFN read)"
  tags        = var.tags

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Permissions for Codebuild
      {
        Effect = "Allow",
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild"
        ],
        Resource = "*"
      },
      # Permissions for Lambda
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction",
          "lambda:ListFunctions"
        ],
        Resource = "*"
      },
      # Permissions for S3
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource = "*"
      },

      # Permissions for IAM
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole",
          "iam:GetRole",
          "iam:ListRoles"
        ],
        "Resource" : "*"
      },
      # Permissions for CodePipeline
      {
        "Effect" : "Allow",
        "Action" : [
          "codepipeline:RetryStageExecution",
          "codepipeline:GetPipelineState",
          "codepipeline:GetPipeline",
          "codepipeline:GetPipelineExecution",
          "codepipeline:StartPipelineExecution",
          "codepipeline:StopPipelineExecution"
        ],
        "Resource" : "*"
      },
      # Permissions for CodeStar Connections
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = "*"
      },
      # Permissions for Logs
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy",
          "logs:PutRetentionPolicy"
        ],
        "Resource" : "*"
      },
      # Permissions for SNS
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_frontend_codepipeline_extras_attach" {
  role       = aws_iam_role.s3_frontend_codepipeline_role[0].name
  policy_arn = aws_iam_policy.s3_frontend_codepipeline_codepipeline_extras.arn
}

