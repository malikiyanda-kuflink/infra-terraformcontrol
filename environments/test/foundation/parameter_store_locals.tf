data "aws_ssm_parameter" "fivetran_gcp_ip" { name = "fivetran_gcp_ip" }
data "aws_ssm_parameter" "office_ips" { name = "kuflink_office_ips" }
data "aws_ssm_parameter" "office_cidr" { name = "on_prem_cidr" }
data "aws_ssm_parameter" "dbt_cloud_ips" { name = "dbt_cloud_ips" }
data "aws_ssm_parameter" "prod_ngw_ip" {name = "prod_ngw_ip"}
data "aws_ssm_parameter" "office_ip" {name = "office_ip"}
data "aws_ssm_parameter" "ssl_certificate_arn" { name = "ssl_certificate_arn"} 
data "aws_ssm_parameter" "staging_codestar_connection" { name = "staging_codestar_connection"} 
data "aws_ssm_parameter" "route53_zone_name" { name = "route53_zone_name"} 
data "aws_ssm_parameter" "route53_hosted_zone_id" { name = "route53_hosted_zone_id"} 
data "aws_ssm_parameter" "cloudfront_zone_id" { name = "cloudfront_zone_id"} 
data "aws_ssm_parameter" "cloudfront_cert_arn" { name = "cloudfront_cert_arn"} 










locals {
  kuflink_office_ips = jsondecode(data.aws_ssm_parameter.office_ips.value)
  dbt_cloud_ips      = jsondecode(data.aws_ssm_parameter.dbt_cloud_ips.value)

  kuflink_office_cidr = [
    {
      description = "kuflink office cidr"
      cidr        = data.aws_ssm_parameter.office_cidr.value
    }
  ]

  fivetran_gcp = [
    {
      description = "FiveTran GCP CIDR (europe-west2 (London))"
      cidr        = data.aws_ssm_parameter.fivetran_gcp_ip.value
    }
  ]
}


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