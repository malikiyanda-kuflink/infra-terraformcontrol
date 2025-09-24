resource "aws_iam_role" "ec2_test_instance_role" {
  count = var.enable_ec2_test_instance_role ? 1 : 0

  # Use explicit name if provided; otherwise derive from name_prefix
  name = coalesce(var.ec2_test_instance_role_name, "${var.name_prefix}-backup-role")

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

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  count      = var.enable_ec2_test_instance_role ? 1 : 0
  role       = aws_iam_role.ec2_test_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
