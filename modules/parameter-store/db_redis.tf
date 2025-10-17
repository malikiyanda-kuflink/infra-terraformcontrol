
# ===================================================================
# REDIS EC2 INSTANCE PARAMETERS
# ===================================================================
data "aws_ssm_parameter" "redis_client" { name = "/backend/${var.environment}/REDIS_CLIENT" }
data "aws_ssm_parameter" "redis_password" { name = "/backend/${var.environment}/REDIS_PASSWORD" }
data "aws_ssm_parameter" "redis_port" { name = "/backend/${var.environment}/REDIS_PORT" }
data "aws_ssm_parameter" "redis_ami_id" { name = "/ec2/${var.environment}/redis_ami_id" }

# ===================================================================
# REDIS ELASTICACHE PARAMETERS
# ===================================================================
data "aws_ssm_parameter" "redis_elastic_cache_php_client" { name = "/backend/${var.environment}/PHP_REDIS_CLIENT" }
data "aws_ssm_parameter" "redis_elastic_cache_password" { name = "/backend/${var.environment}/ELASTIC_CACHE_REDIS_PASSWORD" }
data "aws_ssm_parameter" "redis_elastic_cache_port" { name = "/backend/${var.environment}/ELASTIC_CACHE_REDIS_PORT" }


output "ec2_redis" {
  description = "Redis parameters from ec2_redis.tf"
  value = {
    # EC2 Instance
    client   = data.aws_ssm_parameter.redis_client.value
    password = data.aws_ssm_parameter.redis_password.value
    port     = data.aws_ssm_parameter.redis_port.value
    ami_id   = data.aws_ssm_parameter.redis_ami_id.value
  }
  sensitive = true
}

output "elastic_cache_redis" {
  description = "Redis parameters from ec2_redis.tf"
  value = {
    # ElastiCache
    elastic_cache_php_client = data.aws_ssm_parameter.redis_elastic_cache_php_client.value
    elastic_cache_password   = data.aws_ssm_parameter.redis_elastic_cache_password.value
    elastic_cache_port       = data.aws_ssm_parameter.redis_elastic_cache_port.value
  }
  sensitive = true
}