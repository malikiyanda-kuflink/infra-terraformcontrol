resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "Redis Subnet Group"
  }
}

resource "aws_cloudwatch_log_group" "redis_engine_log" {
  name = "/elasticache/redis-engine-log"

  tags = {
    Name = "Redis Engine Log"
  }
}

resource "aws_cloudwatch_log_group" "redis_slow_log" {
  name = "/elasticache/redis-slow-log"

  tags = {
    Name = "Redis Slow Log"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = var.redis_cluster_id
  description                   = "Redis replication group for Kuflink"
  engine                        = "redis"
  engine_version                = "6.x"
  node_type                     = var.node_type
  port                          = 6379
  num_node_groups               = 1
  replicas_per_node_group       = 0
  automatic_failover_enabled    = false
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids            = [aws_security_group.redis_sg.id]
  transit_encryption_enabled    = true
  auth_token                    = var.redis_elastic_cache_password
  apply_immediately             = true

  log_delivery_configuration {
    destination_type = "cloudwatch-logs"
    destination      = aws_cloudwatch_log_group.redis_engine_log.name
    log_format       = "text"
    log_type         = "engine-log"
  }

  log_delivery_configuration {
    destination_type = "cloudwatch-logs"
    destination      = aws_cloudwatch_log_group.redis_slow_log.name
    log_format       = "text"
    log_type         = "slow-log"
  }

  tags = {
    Name = "Redis Cluster - ${var.redis_cluster_id}"
  }
}
