output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value = var.restore_from_snapshot ? try(module.rds_restore[0].db_instance_arn, null) : try(module.rds[0].db_instance_arn, null)
}

output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value = var.restore_from_snapshot ? try(module.rds_restore[0].db_instance_endpoint, null) : try(module.rds[0].db_instance_endpoint, null)
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value = var.restore_from_snapshot ? try(module.rds_restore[0].db_instance_id, null) : try(module.rds[0].db_instance_id, null)
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value = var.restore_from_snapshot ? try(module.rds_restore[0].db_instance_identifier, null) : try(module.rds[0].db_instance_identifier, null)
}

output "rds_security_group_id" {
  description = "The security group ID for the RDS instance."
  value       = aws_security_group.rds_sg.id
}


output "rds_restore_status" {
  description = "Indicates if RDS was restored from a snapshot, and which snapshot was used if applicable."
  value = var.restore_from_snapshot && var.db_test_snapshot_identifier != "" ? "Restored from snapshot: ${var.db_test_snapshot_identifier}" : "Created new RDS instance (no snapshot)"
}
