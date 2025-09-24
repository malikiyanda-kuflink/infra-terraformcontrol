output "redshift_endpoint" {
  value       = aws_redshift_cluster.restored_primary_redshift_cluster.endpoint
  description = "Redshift cluster endpoint address"
}

output "redshift_endpoint_address" {
  value       = aws_redshift_cluster.restored_primary_redshift_cluster.endpoint
  description = "Hostname of the Redshift cluster (used for DNS CNAME)"
}

output "redshift_port" {
  value       = aws_redshift_cluster.restored_primary_redshift_cluster.port
  description = "Port Redshift is listening on (default: 5439)"
}

output "redshift_database_name" {
  value       = aws_redshift_cluster.restored_primary_redshift_cluster.database_name
  description = "Default database name created during cluster provisioning"
}

output "redshift_cluster_identifier" {
  value       = aws_redshift_cluster.restored_primary_redshift_cluster.cluster_identifier
  description = "Unique identifier of the Redshift cluster"
}

output "redshift_arn" {
  value       = aws_redshift_cluster.restored_primary_redshift_cluster.arn
  description = "ARN of the Redshift cluster"
}

