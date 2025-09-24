# Instance (primary)
output "db_instance_endpoint" { value = aws_db_instance.restored_primary_rds_instance.endpoint }
output "db_instance_identifier" { value = aws_db_instance.restored_primary_rds_instance.identifier }
output "db_instance_id" { value = aws_db_instance.restored_primary_rds_instance.id }
output "db_instance_arn" { value = aws_db_instance.restored_primary_rds_instance.arn }

# Read replica (optional)
output "db_replica_endpoint" { value = try(aws_db_instance.restored_rds_replica[0].endpoint, null) }
output "db_replica_identifier" { value = try(aws_db_instance.restored_rds_replica[0].identifier, null) }
output "db_replica_id" { value = try(aws_db_instance.restored_rds_replica[0].id, null) }
output "db_replica_arn" { value = try(aws_db_instance.restored_rds_replica[0].arn, null) }

# Subnet group & parameter group outputs
# output "db_subnet_group_name"  { value = aws_db_subnet_group.this.name }
# output "db_subnet_group_arn"   { value = aws_db_subnet_group.this.arn }

# output "db_parameter_group_name" { value = aws_db_parameter_group.this.name }
# output "db_parameter_group_arn"  { value = aws_db_parameter_group.this.arn }


# ===== OUTPUTS =====
output "rds_performance_insights_enabled" {
  description = "Whether Performance Insights is enabled"
  value       = aws_db_instance.restored_primary_rds_instance.performance_insights_enabled
}

output "performance_insights_kms_key_id" {
  description = "KMS key ID used for Performance Insights encryption"
  value       = var.create_performance_insights_kms_key ? aws_kms_key.performance_insights[0].key_id : null
}