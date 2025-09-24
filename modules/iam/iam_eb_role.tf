

resource "aws_iam_role" "eb_role" {
  count = var.enable_eb_role ? 1 : 0
  name  = var.eb_role_name
  tags  = var.tags

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
  count = var.enable_eb_role ? 1 : 0
  name  = "inine-${var.name_prefix}-eb-role-policy"
  role  = aws_iam_role.eb_role[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = "arn:aws:sns:eu-west-2:137167813802:ElasticBeanstalkNotifications-Deployments-Kuflink*"
      },
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
        Effect = "Allow",
        Action = [
          "iam:GetInstanceProfile",
          "iam:ListInstanceProfiles",
          "iam:ListRoles",
          "iam:GetRole",
          "iam:AttachRolePolicy"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:UpdateInstanceInformation",
          "ssmmessages:*",
          "ec2messages:*",
          "ssm:ListInstanceAssociations",
          "ssm:DescribeInstanceProperties",
          "ssm:DescribeInstanceInformation"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_instance_profile" "eb_instance_profile" {
  count = var.enable_eb_role ? 1 : 0
  name  = var.eb_instance_profile_name
  role  = aws_iam_role.eb_role[0].name
}

resource "aws_iam_role_policy_attachment" "eb_role_policy" {
  count      = var.enable_eb_role ? 1 : 0
  role       = aws_iam_role.eb_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_role_basic_policy" {
  count      = var.enable_eb_role ? 1 : 0
  role       = aws_iam_role.eb_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "worker_role_beanstalk_policy" {
  count      = var.enable_eb_role ? 1 : 0
  role       = aws_iam_role.eb_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "updates_beanstalk_policy" {
  count      = var.enable_eb_role ? 1 : 0
  role       = aws_iam_role.eb_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_role_policy_attachment" "eb_role_core_policy" {
  count      = var.enable_eb_role ? 1 : 0
  role       = aws_iam_role.eb_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleCore"
}


resource "aws_iam_role_policy_attachment" "ssm_eb_instance_policy" {
  count      = var.enable_eb_role ? 1 : 0
  role       = aws_iam_role.eb_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

