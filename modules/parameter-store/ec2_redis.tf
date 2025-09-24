# ---------------------------------------------------------------#
# Redis EC2 Instance 
# ---------------------------------------------------------------#
data "aws_ssm_parameter" "redis_client" { name = "/backend/staging/REDIS_CLIENT" }
data "aws_ssm_parameter" "redis_host" { name = "/backend/staging/REDIS_HOST" }
data "aws_ssm_parameter" "redis_password" { name = "/backend/staging/REDIS_PASSWORD" }
data "aws_ssm_parameter" "redis_port" { name = "/backend/staging/REDIS_PORT" }


data "aws_ssm_parameter" "redis_test_client" { name = "/backend/test/REDIS_CLIENT" }
# data "aws_ssm_parameter" "redis_test_host" { name = "/backend/test/REDIS_HOST" }
data "aws_ssm_parameter" "redis_test_password" { name = "/backend/test/REDIS_PASSWORD" }
data "aws_ssm_parameter" "redis_test_port" { name = "/backend/test/REDIS_PORT" }

# ---------------------------------------------------------------#
# Redis Elastic Cache 
# ---------------------------------------------------------------#
data "aws_ssm_parameter" "redis_elastic_cache_php_client" { name = "/backend/staging/PHP_REDIS_CLIENT" }
data "aws_ssm_parameter" "new_redis_elastic_cache_password" { name = "/backend/staging/new/EASTIC_CACHE_REDIS_PASSWORD" }
data "aws_ssm_parameter" "redis_elastic_cache_password" { name = "/backend/staging/EASTIC_CACHE_REDIS_PASSWORD" }
data "aws_ssm_parameter" "redis_elastic_cache_port" { name = "/backend/staging/ELASTIC_CACHE_REDIS_PORT" }
# ---------------------------------------------------------------#
