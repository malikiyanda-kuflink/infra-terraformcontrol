module "secrets" {
  source      = "../../../modules/parameter-store"
  environment = local.env
}

output "global" {
  value       = module.secrets.global
  sensitive   = true
} 

output "s3_admin" {
  value = module.secrets.s3_admin
  sensitive = true
}

output "s3_frontend" {
  value = module.secrets.s3_frontend
  sensitive = true
}

output "db_dms" {
  value       = module.secrets.db_dms
  sensitive   = true
} 

output "db_redshift" {
  value  = module.secrets.db_redshift
  sensitive = true
}
output "db_rds" {
  value       = module.secrets.db_rds
  sensitive   = true
}

output "ec2_redis" {
  value       = module.secrets.ec2_redis
  sensitive   = true
}

output "elastic_cache_redis" {
  value       = module.secrets.elastic_cache_redis
  sensitive   = true
}

output "eb_api" {
  value       = module.secrets.eb_api
  description = "Backend api environment variables"
  sensitive   = true
}

output "ec2_bastion" {
  value = module.secrets.ec2_bastion
  sensitive = true
}

output "ec2_metabase" {
  value = module.secrets.ec2_metabase
  sensitive = true
}

output "kuflink_office_cidr" {
  value       = [for ip in local.kuflink_office_cidr : ip.cidr]
  description = "Office CIDRs as list(string)."
  sensitive   = true
}

output "fivetran_gcp_ips" {
  value       = local.fivetran_gcp
  sensitive   = true
  description = "List of DBT Cloud IPs with description and CIDR"
}
