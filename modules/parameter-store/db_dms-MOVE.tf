# ===================================================================
# DMS PARAMETERS
# ===================================================================
data "aws_ssm_parameter" "dms_role_arn" { name = "/${var.environment}/dms_role_arn" }
data "aws_ssm_parameter" "dms_endpoint_access_arn" { name = "/${var.environment}/dms_access_for_endpoint_arn" }
data "aws_ssm_parameter" "dms_logs_role_arn" { name = "/${var.environment}/dms_cloudwatch_logs_role_arn" }
data "aws_ssm_parameter" "dms_rds_target_port" { name = "/kuflink/${var.environment}/rds_port" }

output "db_dms" {
  description = "DMS parameters from db_dms.tf"
  value = {
    role_arn            = data.aws_ssm_parameter.dms_role_arn.value
    endpoint_access_arn = data.aws_ssm_parameter.dms_endpoint_access_arn.value
    logs_role_arn       = data.aws_ssm_parameter.dms_logs_role_arn.value
    rds_target_port     = data.aws_ssm_parameter.dms_rds_target_port.value
  }
  sensitive = true
}

# ===================================================================
# BASTION EC2 PARAMETERS
# ===================================================================
data "aws_ssm_parameter" "bastion_ami_id" { name = "/kuflink/${var.environment}/bastion_ami_id" }
data "aws_ssm_parameter" "bastion_dns_name" { name = "/kuflink/${var.environment}/bastion_dns_name" }
data "aws_ssm_parameter" "bastion_forward_port" { name = "/kuflink/${var.environment}/bastion_forward_port" }
data "aws_ssm_parameter" "bastion_target_port" { name = "/kuflink/${var.environment}/bastion_target_port" }

output "ec2_bastion" {
  description = "Bastion EC2 parameters from ec2_bastion.tf"
  value = {
    ami_id       = data.aws_ssm_parameter.bastion_ami_id.value
    dns_name     = data.aws_ssm_parameter.bastion_dns_name.value
    forward_port = data.aws_ssm_parameter.bastion_forward_port.value
    target_port  = data.aws_ssm_parameter.bastion_target_port.value
  }
  sensitive = true
}

data "aws_ssm_parameter" "kuflink_codestar_connection" {  name = "/autostaging/backend/CODESTAR_CONNECTION"}
data "aws_ssm_parameter" "frontend_codestar_connection" {  name = "/backend/staging/FRONTEND_CONNECTION"}
data "aws_ssm_parameter" "admin_codestar_connection" {  name = "/backend/staging/ADMIN_CONNECTION"}


#remove check main.tf
data "aws_ssm_parameter" "brickfin_ssl_acm" { name = "/backend/staging-test/brickfin_ssl_acm" } 
data "aws_ssm_parameter" "DevOpsKeyPair" { name = "/ec2/default_devopskey" }
data "aws_ssm_parameter" "StagingsKeyPair" { name = "/ec2/default_stagingkey" }

data "aws_ssm_parameter" "DefaultAMI_ID" { name = "/ec2/default_ubuntu_ami" }
data "aws_ssm_parameter" "DefaultInstanceType" { name = "/ec2/default_instance_type" }
data "aws_ssm_parameter" "office_ip" { name = "/ec2/default_ssh_office" }
data "aws_ssm_parameter" "ssl_cert" { name = "/ec2/default_acm_wordpress_ssl" }