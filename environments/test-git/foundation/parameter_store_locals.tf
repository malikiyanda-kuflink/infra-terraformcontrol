data "aws_ssm_parameter" "fivetran_gcp_ip" { name = "fivetran_gcp_ip" }
data "aws_ssm_parameter" "office_ips" { name = "kuflink_office_ips"}
data "aws_ssm_parameter" "dbt_cloud_ips" { name = "dbt_cloud_ips"}


locals {
  kuflink_office_ips = jsondecode(data.aws_ssm_parameter.office_ips.value)
  dbt_cloud_ips = jsondecode(data.aws_ssm_parameter.dbt_cloud_ips.value)


  # kuflink_office_ips = [
  #   {                                                                               
  #     description = "Gravesend Backup Line"
  #     cidr        = "82.152.39.92/32"
  #   },
  #   {
  #     description = "Gravesend Docklands Office"
  #     cidr        = "109.72.216.250/32"
  #   },
  #   {
  #     description = "Gravesend Main Office"
  #     cidr        = "89.197.135.242/32"
  #   }
  # ]

  # dbt_cloud_ips = [
  #   {
  #     description = "DBT cloud IP"
  #     cidr        = "54.81.134.249/32"
  #   },
  #   {
  #     description = "DBT cloud IP"
  #     cidr        = "52.45.144.63/32"
  #   },
  #   {
  #     description = "DBT cloud IP"
  #     cidr        = "34.233.79.135/32"
  #   }
  # ]

  

  fivetran_gcp = [
    {
      description = "FiveTran GCP CIDR (europe-west2 (London))"
      cidr        = data.aws_ssm_parameter.fivetran_gcp_ip
    }
  ]

}

