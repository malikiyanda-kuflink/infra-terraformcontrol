# IAM Role for dbt
resource "aws_iam_role" "dbt_role" {
  count = var.enable_dbt_role ? 1 : 0
  # name = "${var.dbt_role_name}"

  # Use explicit name if provided; otherwise derive from name_prefix
  name = coalesce(var.dbt_role_name, "${var.name_prefix}-dbt-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_instance_profile" "dbt_instance_profile" {
  count = var.enable_dbt_role ? 1 : 0
  name  = "${var.dbt_role_name}-instance-profile"
  role  = aws_iam_role.dbt_role[0].name
}

resource "aws_iam_role_policy_attachment" "ssm_dbt_instance_policy" {
  count      = var.enable_dbt_role ? 1 : 0
  role       = aws_iam_role.dbt_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "dbt_cloudwatch_agent_policy" {
  count      = var.enable_dbt_role ? 1 : 0
  role       = aws_iam_role.dbt_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy" "dbt_inline_policy" {
  count = var.enable_dbt_role ? 1 : 0
  name  = "inine-${var.name_prefix}-dbt-ec2-role-policy"
  role  = aws_iam_role.dbt_role[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permissions for S3
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "ec2:DescribeTags",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics"
        ],
        Resource = "*"
      }
    ]
  })
}




