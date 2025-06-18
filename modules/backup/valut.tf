# Create Backup Vault
resource "aws_backup_vault" "backup_vault" {
  name = var.backup_vault_name

  tags = {
    Name        = var.backup_vault_name
    Environment = var.environment
  }
}

# Optional Vault Lock (highly recommended → protects from accidental delete / ransomware)
resource "aws_backup_vault_lock_configuration" "vault_lock" {
  backup_vault_name   = aws_backup_vault.backup_vault.name
  min_retention_days  = 7
  max_retention_days  = 3650
  changeable_for_days = 7 # allows 7 days grace to change policy → after that Vault is immutable
}