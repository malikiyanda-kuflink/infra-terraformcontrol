# IAM Role for Bastion
resource "aws_iam_role" "bastion_role" {
  count = var.enable_bastion_role ? 1 : 0
  # name = "${var.bastion_role_name}"

  # Use explicit name if provided; otherwise derive from name_prefix
  name = coalesce(var.bastion_role_name, "${var.name_prefix}-bastion-role")

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

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  count = var.enable_bastion_role ? 1 : 0
  name  = "${var.bastion_role_name}-instance-profile"
  role  = aws_iam_role.bastion_role[0].name
}

resource "aws_iam_role_policy_attachment" "ssm_bastion_instance_policy" {
  count      = var.enable_bastion_role ? 1 : 0
  role       = aws_iam_role.bastion_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



