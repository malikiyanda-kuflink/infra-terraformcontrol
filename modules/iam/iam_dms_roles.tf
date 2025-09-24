resource "aws_iam_role" "dms_role" {
  count = var.enable_dms_role ? 1 : 0

  # Use explicit name if provided; otherwise derive from name_prefix
  name = coalesce(var.dms_role_name, "${var.name_prefix}-dms-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "dms.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_dms_vpc_role_policy" {
  count = var.enable_dms_role ? 1 : 0

  role       = aws_iam_role.dms_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}


resource "aws_iam_role" "dms_access_for_endpoint" {
  count = var.enable_dms_access_for_endpoint_role ? 1 : 0
  # Use explicit name if provided; otherwise derive from name_prefix
  name = coalesce(var.dms_access_for_endpoint_role_name, "${var.name_prefix}-dms_access_for_endpoint_role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = ["dms.amazonaws.com", "redshift.amazonaws.com"]
      },

      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}


resource "aws_iam_role" "dms_cloudwatch_logs" {
  count = var.enable_dms_cw_logs_role ? 1 : 0

  # Use explicit name if provided; otherwise derive from name_prefix
  name = coalesce(var.dms_cloudwatch_logs_role_name, "${var.name_prefix}-dms-cloudwatch_logs_role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_logs_policy" {
  count      = var.enable_dms_cw_logs_role ? 1 : 0
  role       = aws_iam_role.dms_cloudwatch_logs[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}
