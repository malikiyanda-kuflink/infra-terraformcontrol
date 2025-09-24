resource "aws_iam_role" "metabase_role" {
  count = var.enable_metabase_role ? 1 : 0
  name  = var.metabase_role_name

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

resource "aws_iam_policy" "cw_logging_policy" {
  name = "${var.name_prefix}-Metabase-EC2-CloudWatchAgentServerPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "cloudwatch:PutMetricData",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })

  tags = var.tags
}

resource "aws_iam_instance_profile" "metabase_ec2_instance_profile" {
  count = var.enable_metabase_role ? 1 : 0
  name  = "${var.name_prefix}-metabase-ec2_instance_profile"
  role  = aws_iam_role.metabase_role[0].name
}

resource "aws_iam_role_policy_attachment" "cw_logging_attachment" {
  count      = var.enable_metabase_role ? 1 : 0
  role       = aws_iam_role.metabase_role[0].name
  policy_arn = aws_iam_policy.cw_logging_policy.arn
}

# Attach the necessary policies for EC2
resource "aws_iam_role_policy_attachment" "ec2_instance_policy" {
  count      = var.enable_metabase_role ? 1 : 0
  role       = aws_iam_role.metabase_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm_instance_policy" {
  count      = var.enable_metabase_role ? 1 : 0
  role       = aws_iam_role.metabase_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  count      = var.enable_metabase_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.metabase_role[0].name
}