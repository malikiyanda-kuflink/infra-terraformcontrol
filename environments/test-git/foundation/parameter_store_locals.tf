data "aws_ssm_parameter" "fivetran_gcp_ip" { name = "fivetran_gcp_ip" }
data "aws_ssm_parameter" "office_ips" { name = "kuflink_office_ips"}
data "aws_ssm_parameter" "dbt_cloud_ips" { name = "dbt_cloud_ips"}


locals {
  kuflink_office_ips = jsondecode(data.aws_ssm_parameter.office_ips.value)
  dbt_cloud_ips = jsondecode(data.aws_ssm_parameter.dbt_cloud_ips.value)

  fivetran_gcp = [
    {
      description = "FiveTran GCP CIDR (europe-west2 (London))"
      cidr        = data.aws_ssm_parameter.fivetran_gcp_ip
    }
  ]
}

