output "backup_vault_arn" {
  value = aws_backup_vault.backup_vault.arn
}

output "backup_plan_id" {
  value = aws_backup_plan.backup_plan.id
}

output "backup_selection_id" {
  value = aws_backup_selection.backup_selection.id
}
