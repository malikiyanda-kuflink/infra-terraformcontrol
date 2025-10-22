# IAM Role for dbt
resource "aws_iam_role" "codedeploy_service_role" {
  count = var.enable_codedeploy_service_role ? 1 : 0

  # Use explicit name if provided; otherwise derive from name_prefix
  name = coalesce(var.codedeploy_service_role_name, "${var.name_prefix}-code-deploy-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach AWS managed policy with CodeDeploy permissions
resource "aws_iam_role_policy_attachment" "codedeploy_service_role" {
  role       = aws_iam_role.codedeploy_service_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}



