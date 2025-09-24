# Fetch caller identitys
data "aws_caller_identity" "current" {}

# RDS Instance
resource "aws_db_instance" "new_primary_rds_instance" {
  db_name = var.db_database

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  identifier        = var.db_name_identifier
  username          = var.db_username
  password          = var.db_password

  parameter_group_name   = var.db_parameter_group_name
  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = var.db_subnet_group_name

  copy_tags_to_snapshot               = true
  backup_retention_period             = var.backup_retention_period
  skip_final_snapshot                 = var.skip_final_snapshot
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  publicly_accessible                 = var.publicly_accessible
  deletion_protection                 = var.deletion_protection
  multi_az                            = var.multi_az
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  storage_encrypted                   = var.storage_encrypted

  tags = { Name = var.db_name_identifier, Role = "primary" }

  lifecycle {
    ignore_changes = [
      db_name,
      username,
      password,
    ]
  }
}

