data "aws_caller_identity" "current" {}

locals {
  ssh_key_ssm_arn = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.ssh_key_parameter_name}"
}


resource "aws_iam_instance_profile" "ec2_test_instance_profile" {
  name = "ec2-test-instance-profile"
  role = aws_iam_role.ec2_test_role.name
}



# IAM Role for Ec2
resource "aws_iam_role" "ec2_test_role" {
  name = "ec2-test-ec2-role"

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
    Name = "ec2-test-ec2-role"
  }
}

resource "aws_iam_policy" "ec2_test_ssm_policy" {
  name        = "ec2-test-ssm-getparameter"
  description = "Allow Test EC2 to GetParameter for staging PEM"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter"
        ],
        "Resource" : "arn:aws:ssm:eu-west-2:137167813802:parameter/kuflink/ssh/staging_pem"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "redshift:DescribeClusters"
        ],
        "Resource" : "*"
      }
    ]
    }
  )
}


resource "aws_iam_role_policy_attachment" "ec2_test_attach_ssm_policy" {
  role       = aws_iam_role.ec2_test_role.name
  policy_arn = aws_iam_policy.ec2_test_ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_instance_policy" {
  role       = aws_iam_role.ec2_test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



