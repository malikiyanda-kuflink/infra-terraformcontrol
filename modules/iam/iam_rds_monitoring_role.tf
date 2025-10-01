# ===== IAM ROLE FOR ENHANCED MONITORING =====
# Required for Enhanced Monitoring (60-second granularity)
resource "aws_iam_role" "rds_enhanced_monitoring_role" {
  count = var.enable_rds_enhanced_monitoring_role ? 1 : 0

  # name = "${var.name_prefix}-rds-enhanced-monitoring-role"
  # Use explicit name if provided; otherwise derive from name_prefix
  name = coalesce(var.rds_enhanced_monitoring_role_name, "${var.name_prefix}-rds-enhanced-monitoring")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  # tags = {
  #   Name = "${var.name_prefix}-rds-enhanced-monitoring"
  #   Purpose = "RDS Enhanced Monitoring"
  # }
  tags = var.tags
}


# Attach the AWS managed policy for RDS Enhanced Monitoring
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.enable_rds_enhanced_monitoring_role ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}





