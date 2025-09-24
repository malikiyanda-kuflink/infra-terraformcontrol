
resource "aws_iam_role" "backup_role" {
  count = var.enable_backup_role ? 1 : 0

  # Use explicit name if provided; otherwise derive from name_prefix
  name = coalesce(var.backup_role_name, "${var.name_prefix}-backup-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup_role_policy_attach" {
  count      = var.enable_backup_role ? 1 : 0
  role       = aws_iam_role.backup_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
