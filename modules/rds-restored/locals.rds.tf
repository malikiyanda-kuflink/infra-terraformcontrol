# Get current AWS account ID
data "aws_caller_identity" "current" {}

locals {
  identifier = var.db_name_identifier
  # RDS SQL Server primary instance
  db_instance_id   = var.db_name_identifier
  db_instance_name = var.db_name_identifier


  # Optional replica (count = var.create_read_replica ? 1 : 0)
  replica_instance_name = try(one(aws_db_instance.restored_rds_replica[*].identifier), null)
  replica_instance_id   = try(one(aws_db_instance.restored_rds_replica[*].id), null)
}
