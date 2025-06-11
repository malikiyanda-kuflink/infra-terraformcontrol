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

output "rds_security_group_id" {
  description = "The security group ID for the RDS instance."
  value       = aws_security_group.rds_sg.id
}

output "db_instance_arn" {
  value = aws_db_instance.rds_db.arn
}

