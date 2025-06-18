data "aws_caller_identity" "current" {}


resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${var.bastion_name}-instance-profile"
  role = aws_iam_role.bastion_role.name
}



# IAM Role for Bastion
resource "aws_iam_role" "bastion_role" {
  name = "${var.bastion_name}-ec2-role"

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

  tags = {
    Name = "${var.bastion_name}-ec2-role"
  }
}

resource "aws_iam_policy" "bastion_ssm_policy" {
  name        = "${var.bastion_name}-ssm-getparameter"
  description = "Allow Bastion EC2 to GetParameter for staging PEM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.ssh_key_parameter_name}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_attach_ssm_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_ssm_policy.arn
}



