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



