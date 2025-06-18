output "redis_endpoint" {
  description = "Primary endpoint for Redis"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  description = "Port Redis is listening on"
  value       = aws_elasticache_replication_group.redis.port
}
