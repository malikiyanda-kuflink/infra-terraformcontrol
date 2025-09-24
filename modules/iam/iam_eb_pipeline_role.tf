############################################
# VARIABLES
############################################
variable "eb_managed_policy_arns" {
  type        = list(string)
  description = "Managed policies to attach to the CodePipeline role"
  # Add/override at the layer if needed.
  default = [
    "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  ]
}

############################################
# ROLE
############################################
resource "aws_iam_role" "eb_codepipeline_role" {
  count = var.enable_eb_codepipeline_role ? 1 : 0
  name  = var.eb_codepipeline_role_name
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
resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.eb_managed_policy_arns)
  role       = aws_iam_role.eb_codepipeline_role[0].name
  policy_arn = each.value
}

############################################
# ONE CUSTOM "EXTRAS" POLICY (LEFTOVERS)
############################################
# - codestar-connections:UseConnection (scoped or *)
# - iam:PassRole (scoped list or *)
# - EB API calls used during deploy
# - CloudFormation READ (scoped to EB stacks) to satisfy GetTemplate, Describe*, etc.
resource "aws_iam_policy" "codepipeline_extras" {
  name        = "${var.name_prefix}-eb-codepipeline_extras"
  description = "extras for CodePipeline (CodeStar, PassRole, EB API, CFN read)"
  tags        = var.tags

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Permissions for EC2
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances",              # Allows describing EC2 instances
          "ec2:DescribeSecurityGroups",         # Allows describing security groups
          "ec2:DescribeSubnets",                # Allows describing subnets
          "ec2:DescribeVpcs",                   # Allows describing VPCs
          "ec2:DescribeNetworkInterfaces",      # Allows describing network interfaces
          "ec2:DescribeLaunchTemplateVersions", # Allows describing launch template versions
          "ec2:DescribeKeyPairs",               # Allows describing EC2 key pairs
          "ec2:DescribeImages",                 # Allows describing EC2 AMIs
          "ec2:RunInstances",                   # Allows launching EC2 instances
          "ec2:TerminateInstances",             # Allows terminating EC2 instances
          "ec2:StartInstances",                 # Allows starting EC2 instances
          "ec2:StopInstances",                  # Allows stopping EC2 instances
          "ec2:RebootInstances",                # Allows rebooting EC2 instances
          "ec2:DescribeAvailabilityZones",      # Allows describing availability zones
          "ec2:DescribeTags",                   # Allows describing resource tags
          "ec2:DescribeVolumes",                # Allows describing EBS volumes
          "ec2:DescribeSnapshots",              # Allows describing EBS snapshots
          "ec2:DescribeInstanceStatus",         # Allows describing the status of EC2 instances
          "ec2:DescribeAddresses",              # Allows describing Elastic IP addresses
          "ec2:DescribeRouteTables",            # Allows describing route tables
          "ec2:DescribeInternetGateways",       # Allows describing internet gateways
          "ec2:DescribeNatGateways",            # Allows describing NAT gateways
          "ec2:DescribeLaunchTemplates"         # Allows describing launch templates
        ],
        "Resource" : "*"
      },


      # # Permissions for Auto Scaling
      # {
      #   "Effect" : "Allow",
      #   "Action" : [
      #     "autoscaling:DescribeAutoScalingGroups",
      #     "autoscaling:DescribeLaunchConfigurations",
      #     "autoscaling:DescribePolicies",
      #     "autoscaling:DescribeScalingActivities",
      #     "autoscaling:DescribeTags",
      #     "autoscaling:CreateLaunchConfiguration",
      #     "autoscaling:UpdateAutoScalingGroup",
      #     "autoscaling:DeleteAutoScalingGroup",
      #     "autoscaling:TerminateInstanceInAutoScalingGroup",
      #     "autoscaling:SuspendProcesses",
      #     "autoscaling:ResumeProcesses",
      #     "autoscaling:SetDesiredCapacity",
      #     "autoscaling:EnableMetricsCollection",
      #     "autoscaling:DisableMetricsCollection",
      #     "autoscaling:CreateAutoScalingGroup", #Required for Immutable Deployments
      #     "autoscaling:AttachLoadBalancerTargetGroups",
      #     "autoscaling:AttachInstances",
      #     "autoscaling:DetachInstances",
      #     "autoscaling:PutScalingPolicy",
      #     "autoscaling:PutScheduledUpdateGroupAction",
      #     "autoscaling:DeleteLaunchConfiguration"
      #   ],
      #   "Resource" : "*"
      # },

      {
        "Effect" : "Allow",
        "Action" : "autoscaling:*", # ✅ Grants Full Auto Scaling Permissions
        "Resource" : "*"
      },

      # Permissions for Elastic Beanstalk
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticbeanstalk:DescribeEnvironments",
          "elasticbeanstalk:CreateEnvironment",
          "elasticbeanstalk:TerminateEnvironment",
          "elasticbeanstalk:UpdateEnvironment",
          "elasticbeanstalk:DescribeEvents",
          "elasticbeanstalk:DescribeApplicationVersions",
          "elasticbeanstalk:CreateApplicationVersion",
          "elasticbeanstalk:DeleteApplicationVersion",
          "elasticbeanstalk:RebuildEnvironment",
          "elasticbeanstalk:DescribeEnvironmentManagedActions",
          "elasticbeanstalk:ApplyEnvironmentManagedAction"
        ],
        "Resource" : "*"
      },
      # Permissions for CloudFormation
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResources",
          "cloudformation:DescribeStackResource",
          "cloudformation:CreateStack",
          "cloudformation:UpdateStack",
          "cloudformation:DeleteStack",
          "cloudformation:CancelUpdateStack",
          "cloudformation:GetTemplate",
          "cloudformation:ValidateTemplate",
          "cloudformation:ListStackResources",
          "cloudformation:GetStackPolicy",
          "cloudformation:SetStackPolicy"
        ],
        "Resource" : "*"
      },
      # Permissions for S3
      # {
      #   "Effect" : "Allow",
      #   "Action" : [
      #     "s3:CreateBucket",               # Allows creating S3 buckets
      #     "s3:DeleteBucket",               # Allows deleting S3 buckets
      #     "s3:ListAllMyBuckets",           # Allows listing all buckets
      #     "s3:GetBucketLocation",          # Allows retrieving the bucket location
      #     "s3:ListBucket",                 # Allows listing objects in a bucket
      #     "s3:GetObject",                  # Allows retrieving objects from S3
      #     "s3:GetObjectAcl",               # Allows retrieving object ACLs
      #     "s3:PutObject",                  # Allows uploading objects to S3
      #     "s3:PutObjectAcl",               # Allows setting object ACLs
      #     "s3:DeleteObject",               # Allows deleting objects in S3
      #     "s3:PutBucketPolicy",            # Allows setting bucket policies
      #     "s3:GetBucketPolicy",            # Allows getting bucket policies
      #     "s3:PutBucketTagging",           # Allows adding bucket tags
      #     "s3:GetBucketTagging",           # Allows retrieving bucket tags
      #     "s3:AbortMultipartUpload",       # Allows aborting multipart uploads
      #     "s3:PutLifecycleConfiguration",  # Allows setting lifecycle rules
      #     "s3:GetLifecycleConfiguration",  # Allows retrieving lifecycle rules
      #     "s3:PutBucketLogging",           # Allows setting bucket logging
      #     "s3:GetBucketLogging",           # Allows retrieving bucket logging
      #     "s3:PutBucketEncryption",        # Allows enabling bucket encryption
      #     "s3:GetBucketEncryption"         # Allows retrieving bucket encryption settings
      #   ],
      #   "Resource" : "*"
      # },

      {
        "Action" : "s3:*",
        "Effect" : "Allow",
        "Resource" : "*"
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
      # Permissions for CodeBuild
      {
        "Effect" : "Allow",
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild",
          "codebuild:BatchGetProjects"
        ],
        "Resource" : "*"
      },
      # Permissions for Elastic Load Balancing (Rollback scenarios)
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:ModifyTargetGroup"
        ],
        "Resource" : "*"
      },
      # Permissions for CodeStar Connections
      {
        "Effect" : "Allow",
        "Action" : [
          "codestar-connections:UseConnection"
        ],
        "Resource" : "*"
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
        "Effect" : "Allow",
        "Action" : "sns:*",
        # "Action" : [
        #   "sns:Publish",
        #   "sns:CreateTopic",
        #   "sns:DeleteTopic",
        #   "sns:SetTopicAttributes",
        #   "sns:Subscribe",
        #   "sns:Unsubscribe"
        # ]
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "extras_attach" {
  role       = aws_iam_role.eb_codepipeline_role[0].name
  policy_arn = aws_iam_policy.codepipeline_extras.arn
}

