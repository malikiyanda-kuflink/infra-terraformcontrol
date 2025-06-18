output "db_instance_endpoint" {
  description = "The connection endpoint for the database instance."
  value       = aws_db_instance.rds_db.endpoint
}

output "db_instance_identifier" {
  description = "The identifier of the database instance."
  value       = aws_db_instance.rds_db.identifier
}

output "db_instance_id" {
  description = "The instance ID."
  value       = aws_db_instance.rds_db.id
}

output "db_instance_arn" {
  description = "The ARN of the database instance."
  value       = aws_db_instance.rds_db.arn
}
