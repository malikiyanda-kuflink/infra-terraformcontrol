#################################
# S3 Admin
#################################
output "s3_admin" {
  description = "S3 + CloudFront frontend details (null when disabled)."
  value = local.enable_s3_admin ? {
    bucket_name             = module.s3-admin.bucket_name
    bucket_arn              = module.s3-admin.bucket_arn
    cloudfront_id           = module.s3-admin.cloudfront_id
    cloudfront_domain       = module.s3-admin.cloudfront_domain_name
    website_url             = local.admin_website_url
    website_backend_api_url = local.api_url
  } : null
}

output "s3_admin_pipeline" {
  value = module.s3-admin.admin_pipeline
}


#################################
# DBT Host
#################################
output "ec2_dbt" {
  description = "DBT host details (null when disabled)."
  value = local.enable_dbt ? {
    instance_id = module.ec2-dbt[0].dbt_instance_id
    private_ip  = module.ec2-dbt[0].dbt_private_ip
  } : null
}


#################################
# S3 Frontend
#################################
output "s3_frontend" {
  description = "S3 + CloudFront frontend details (null when disabled)."
  value = local.enable_s3_frontend ? {
    bucket_name             = module.s3-frontend.bucket_name
    bucket_arn              = module.s3-frontend.bucket_arn
    cloudfront_id           = module.s3-frontend.cloudfront_id
    cloudfront_domain       = module.s3-frontend.cloudfront_domain_name
    website_url             = local.frontend_website_url
    website_backend_api_url = local.api_url
  } : null
}

output "s3_frontend_maintenance" {
  description = "S3 + CloudFront frontend details (null when disabled)."
  value = local.enable_s3_frontend ? {
    bucket_name = module.s3-frontend.maintenance_bucket_name
    bucket_arn  = module.s3-frontend.maintenance_bucket_arn
    # cloudfront_id           = module.s3-frontend.maintenance_cloudfront_id
    # cloudfront_domain       = module.s3-frontend.cloudfront_domain_name
    # website_url             = local.maintenance_frontend_website_url 
    website_backend_api_url = "static-page"
  } : null
}

output "s3_frontend_pipeline" {
  value = module.s3-frontend.frontend_pipeline
}

output "s3_frontend_maintenance_pipeline" {
  value = module.s3-frontend.maintenance_pipeline
}
#################################
# Bastion 
#################################
output "ec2_bastion" {
  description = "Bastion details (null when disabled)."
  value = local.enable_bastion ? {
    instance_id = module.ec2-bastion[0].bastion_instance_id
    public_ip   = module.ec2-bastion[0].bastion_elastic_ip
    private_ip  = module.ec2-bastion[0].bastion_private_ip
  } : null
}

#################################
# Elastic Beanstalk (EB) 
#################################
# Keep your existing p2papi_cname output if you like; this just groups the EB env bits.
output "eb_app" {
  description = "Elastic Beanstalk app details (null when disabled)."
  value = local.enable_eb ? {
    web_env_name    = try(module.eb-api[0].eb_environment_name, module.eb-api[0].web_env_name, null)
    worker_env_name = try(module.eb-api[0].eb_worker_environment_name, module.eb-api[0].worker_env_name, null)
    endpoint_url    = try(module.eb-api[0].environment_url, module.eb-api[0].web_env_cname, null)
  } : null
}

# Your existing grouped CNAME (kept as-is)
output "eb_p2papi_cname" {
  description = "Details for the API CNAME"
  value = local.enable_eb ? {
    name   = aws_route53_record.p2papi_cname[0].name
    fqdn   = aws_route53_record.p2papi_cname[0].fqdn
    type   = aws_route53_record.p2papi_cname[0].type
    ttl    = aws_route53_record.p2papi_cname[0].ttl
    record = one(aws_route53_record.p2papi_cname[0].records)
  } : null
}

# ===================================================================
# Redis Security Group ID
# ===================================================================

output "redis_sg_id" {
  value = aws_security_group.redis_sg.id
}

#################################
# WAF (EB - Elastic Beanstalk ALB)
#################################
output "eb_waf" {
  description = "Key WAF details for EB ALB (trimmed). Null when WAF is disabled."
  value = local.enable_eb_waf ? {
    web_acl_arn    = module.eb_waf[0].web_acl_arn
    web_acl_name   = module.eb_waf[0].web_acl_name
    scope          = module.eb_waf[0].web_acl_scope
    log_group_name = try(module.eb_waf[0].log_group_name, null)
    rules_active   = module.eb_waf[0].rules_active
  } : null
}

#################################
# WAF (S3 Admin - CloudFront)
#################################
output "s3_admin_waf" {
  description = "Key WAF details for S3 Admin (trimmed). Null when WAF is disabled."
  value = local.enable_s3_admin_waf ? {
    web_acl_arn    = module.s3_admin_waf[0].web_acl_arn
    web_acl_name   = module.s3_admin_waf[0].web_acl_name
    scope          = module.s3_admin_waf[0].web_acl_scope
    log_group_name = try(module.s3_admin_waf[0].log_group_name, null)
    rules_active   = module.s3_admin_waf[0].rules_active
  } : null
}


#################################
# OPTIONAL / FUTURE MODULES
# Uncomment only if the module is declared with `count` and a toggle.
#################################

# # ElastiCache Redis (requires module "redis_elastic_cache" with count and a toggle like local.enable_redis_elasticache)
# output "redis_primary_endpoint_address" {
#   description = "Primary endpoint address for Redis ElastiCache"
#   value       = local.enable_redis_elasticache ? module.redis_elastic_cache[0].redis_endpoint : null
# }
# output "redis_elastic_cache_php_client" {
#   description = "Redis client connection string for PHP"
#   value       = local.enable_redis_elasticache ? "tcp://${module.redis_elastic_cache[0].redis_endpoint}:6379" : null
# }
# output "redis_elastic_cache_port" {
#   description = "Redis port"
#   value       = local.enable_redis_elasticache ? module.redis_elastic_cache[0].redis_port : null
# }

# # WordPress EC2 (requires module "ec2_wordpress" with count and a toggle like local.enable_wordpress)
# output "wordpress_test_instance_private_ip" {
#   value = local.enable_wordpress ? module.ec2_wordpress[0].wordpress_test_instance_private_ip : null
# }
# output "wordpress_test_instance_id" {
#   value = local.enable_wordpress ? module.ec2_wordpress[0].wordpress_test_instance_id : null
# }
# output "wordpress_test_instance_arn" {
#   value = local.enable_wordpress ? module.ec2_wordpress[0].wordpress_test_instance_arn : null
# }

# # Generic EC2 Test Instance (requires module "ec2_test_instance" with count and a toggle like local.enable_test_instance)
# output "test_instance_arn" {
#   description = "ARN of the EC2 test instance"
#   value       = local.enable_test_instance ? module.ec2_test_instance[0].test_instance_arn : null
# }
# output "test_instance_id" {
#   description = "ID of the EC2 test instance"
#   value       = local.enable_test_instance ? module.ec2_test_instance[0].test_instance_id : null
# }
# output "test_instance_private_ip" {
#   description = "Private IP of the EC2 test instance"
#   value       = local.enable_test_instance ? module.ec2_test_instance[0].test_instance_private_ip : null
# }