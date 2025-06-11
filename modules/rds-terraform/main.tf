# Fetch caller identity
data "aws_caller_identity" "current" {}

# RDS Instance
resource "aws_db_instance" "rds_db" {
  allocated_storage          = var.allocated_storage
  storage_type               = var.storage_type
  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  identifier                 = var.db_test_name_identifier
  username                   = var.db_test_username
  password                   = var.db_test_password

  snapshot_identifier        = var.restore_from_snapshot ? var.db_test_snapshot_identifier : null
  db_name                    = var.restore_from_snapshot ? null : var.db_test_database

  parameter_group_name       = var.db_parameter_group_name
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]

  backup_retention_period    = var.backup_retention_period
  skip_final_snapshot        = var.skip_final_snapshot
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  publicly_accessible        = var.publicly_accessible
  deletion_protection        = var.deletion_protection
  multi_az                   = var.multi_az
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  storage_encrypted          = var.storage_encrypted

  tags = {
    Name        = var.rds_name_tag
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      db_name,
      password,
      snapshot_identifier
    ]
  }
}

