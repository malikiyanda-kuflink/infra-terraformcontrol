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