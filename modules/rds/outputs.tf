output "db_instance_endpoint" {
  description = "The connection endpoint for the database instance."
  value       = aws_db_instance.new_primary_rds_instance.endpoint
}

output "db_instance_identifier" {
  description = "The identifier of the database instance."
  value       = aws_db_instance.new_primary_rds_instance.identifier
}

output "db_instance_id" {
  description = "The instance ID."
  value       = aws_db_instance.new_primary_rds_instance.id
}

output "db_instance_arn" {
  description = "The ARN of the database instance."
  value       = aws_db_instance.new_primary_rds_instance.arn
}

output "db_replica_endpoint" {
  description = "The connection endpoint for the read replica"
  value       = try(aws_db_instance.new_rds_replica[0].endpoint, null)
}

output "db_replica_identifier" {
  description = "The identifier of the read replica"
  value       = try(aws_db_instance.new_rds_replica[0].identifier, null)
}

output "db_replica_id" {
  description = "The ID of the read replica"
  value       = try(aws_db_instance.new_rds_replica[0].id, null)
}

output "db_replica_arn" {
  description = "The ARN of the read replica"
  value       = try(aws_db_instance.new_rds_replica[0].arn, null)
}

