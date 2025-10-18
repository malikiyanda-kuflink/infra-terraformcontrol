
output "kuflink_office_ips" {
  value       = local.kuflink_office_ips
  description = "List of Kuflink office IPs with description and CIDR"
  sensitive   = true
}

output "dbt_cloud_ips" {
  value       = local.dbt_cloud_ips
  sensitive   = true
  description = "List of DBT Cloud IPs with description and CIDR"
}

output "prod_ngw_ip" {
  value       = data.aws_ssm_parameter.prod_ngw_ip.value
  sensitive   = true
  description = "Production NAT Gateway IP"
}

output "office_ip" {
  value       = data.aws_ssm_parameter.office_ip.value
  sensitive   = true
  description = "Office IP"
}

output "ssl_certificate_arn" {
  value       = data.aws_ssm_parameter.ssl_certificate_arn.value
  sensitive   = true
  description = "Brickfin SSL ARN"
}


output "staging_codestar_connection" {
  value       = data.aws_ssm_parameter.staging_codestar_connection.value
  sensitive   = true
  description = "Staging Codestar Connection"
}

output "route53_zone_name" {
  value       = data.aws_ssm_parameter.route53_zone_name.value
  sensitive   = true
  description = "Route 53 Hosted Zone Name"
}

output "route53_hosted_zone_id" {
  value       = data.aws_ssm_parameter.route53_hosted_zone_id.value
  sensitive   = true
  description = "Route 53 Hosted Zone ID"
}


output "cloudfront_zone_id" {
  value       = data.aws_ssm_parameter.cloudfront_zone_id.value
  sensitive   = true
  description = "Cloudfront Zone ID"
}

output "cloudfront_cert_arn" {
  value       = data.aws_ssm_parameter.cloudfront_cert_arn.value
  sensitive   = true
  description = "Cloudfront ACM Cert ARN"
}

output "office_cidr" {
  value       = data.aws_ssm_parameter.office_cidr.value
  sensitive   = true
  description = "On Prem CIDR"
}



output "global" {
  value     = module.secrets.global
  sensitive = true
}

output "s3_admin" {
  value     = module.secrets.s3_admin
  sensitive = true
}

output "s3_frontend" {
  value     = module.secrets.s3_frontend
  sensitive = true
}

output "db_redshift" {
  value     = module.secrets.db_redshift
  sensitive = true
}
output "db_rds" {
  value     = module.secrets.db_rds
  sensitive = true
}

output "ec2_redis" {
  value     = module.secrets.ec2_redis
  sensitive = true
}

output "elastic_cache_redis" {
  value     = module.secrets.elastic_cache_redis
  sensitive = true
}

output "eb_api" {
  value       = module.secrets.eb_api
  description = "Backend api environment variables"
  sensitive   = true
}

output "ec2_metabase" {
  value     = module.secrets.ec2_metabase
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