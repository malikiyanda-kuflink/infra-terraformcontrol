# Create Backup Plan with 4 Rules

# Daily Rule
resource "aws_backup_plan" "backup_plan" {
  name = var.backup_plan_name

  rule {
    rule_name         = "${var.backup_plan_name}-daily"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 5 * * ? *)" # Every day at 05:00 UTC

    lifecycle {
      delete_after = 35 # Keep for 35 days
    }
  }

  # Weekly Rule
  rule {
    rule_name         = "${var.backup_plan_name}-weekly"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 6 ? * 2 *)" # Every Monday 06:00 UTC

    lifecycle {
      delete_after = 84 # 12 weeks ≈ 84 days
    }
  }

  # Monthly Rule
  rule {
    rule_name         = "${var.backup_plan_name}-monthly"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 7 1 * ? *)" # 1st of month 07:00 UTC

    lifecycle {
      delete_after = 365 # 12 months
    }
  }

  # Yearly Rule
  rule {
    rule_name         = "${var.backup_plan_name}-yearly"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 8 1 1 ? *)" # January 1st 08:00 UTC

    lifecycle {
      delete_after = 2555 # 7 years ≈ 2555 days
    }
  }

  tags = {
    Name        = var.backup_plan_name
    Environment = var.environment
  }
}

# Backup Selection → target resources (RDS + EC2)
resource "aws_backup_selection" "backup_selection" {
  iam_role_arn = var.backup_service_role_arn
  name         = "${var.backup_plan_name}-selection"
  plan_id      = aws_backup_plan.backup_plan.id

  resources = [
    var.rds_instance_arn,
    var.ec2_instance_arn
  ]
}
