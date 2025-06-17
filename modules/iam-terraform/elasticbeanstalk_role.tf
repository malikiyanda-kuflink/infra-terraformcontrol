resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = var.eb_instance_profile_name
  role = aws_iam_role.eb_role.name
}

resource "aws_iam_role" "eb_role" {
  name = var.eb_role_name

  tags = {
    Description = "ElasticBeanstalk EC2 Role"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "elasticbeanstalk.amazonaws.com", "sns.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eb_inline_policy" {
  name = "eb_inline_policy"
  role = aws_iam_role.eb_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # {
      #   Effect   = "Allow"
      #   Action   = "sns:Publish"
      #   Resource = "${aws_sns_topic.eb_notifications.arn}"
      # },

      # {
      #   Effect = "Allow"
      #   Action = [
      #     "s3:CreateBucket", "s3:DeleteBucket", "s3:ListAllMyBuckets",
      #     "s3:GetBucketLocation", "s3:ListBucket", "s3:GetObject",
      #     "s3:GetObjectAcl", "s3:PutObject", "s3:PutObjectAcl",
      #     "s3:DeleteObject", "s3:PutBucketPolicy", "s3:GetBucketPolicy",
      #     "s3:PutBucketTagging", "s3:GetBucketTagging",
      #     "s3:AbortMultipartUpload", "s3:PutLifecycleConfiguration",
      #     "s3:GetLifecycleConfiguration", "s3:PutBucketLogging",
      #     "s3:GetBucketLogging", "s3:PutBucketEncryption",
      #     "s3:GetBucketEncryption"
      #   ]
      #   Resource = [
      #     "arn:aws:s3:::${var.codepipeline_artifacts_bucket_name}",
      #     "arn:aws:s3:::${var.codepipeline_artifacts_bucket_name}/*"
      #   ]
      # },

      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage", "sqs:ReceiveMessage",
          "sqs:DeleteMessage", "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "elasticache:DescribeCacheClusters", "elasticache:ListTagsForResource",
          "elasticache:DescribeCacheSubnetGroups", "elasticache:DescribeReplicationGroups",
          "elasticache:DescribeCacheSecurityGroups"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter", "ssm:GetParameters",
          "ssm:GetParameterHistory", "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eb_role_policy" {
  role       = aws_iam_role.eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_role_basic_policy" {
  role       = aws_iam_role.eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "worker_role_beanstalk_policy" {
  role       = aws_iam_role.eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "updates_beanstalk_policy" {
  role       = aws_iam_role.eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_role_policy_attachment" "eb_role_core_policy" {
  role       = aws_iam_role.eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleCore"
}
