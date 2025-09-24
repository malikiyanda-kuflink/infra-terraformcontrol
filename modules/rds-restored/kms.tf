# ===== OPTIONAL: KMS KEY FOR PERFORMANCE INSIGHTS =====
# Create KMS key for Performance Insights encryption (optional)
resource "aws_kms_key" "performance_insights" {
  count = var.create_performance_insights_kms_key ? 1 : 0
  
  description = "KMS key for RDS Performance Insights - ${var.db_name_identifier}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS Performance Insights"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.db_name_identifier}-performance-insights-key"
    Purpose = "RDS Performance Insights Encryption"
  }
}

resource "aws_kms_alias" "performance_insights" {
  count = var.create_performance_insights_kms_key ? 1 : 0
  
  name          = "alias/${var.db_name_identifier}-performance-insights"
  target_key_id = aws_kms_key.performance_insights[0].key_id
}