
# ---------------------------------------------------------------#
# Shared Variables
# ---------------------------------------------------------------#
data "aws_ssm_parameter" "account_id" { name = "account_id" }
data "aws_ssm_parameter" "canonical_id" { name = "canonical_id" }

# data "aws_ssm_parameter" "ssh_key_parameter_name" { name = "DevOpsPublicKey" }
data "aws_ssm_parameter" "TeamLeadPublicKey" { name = "TeamLeadPublicKey" }
data "aws_ssm_parameter" "DevOpsPublicKey" { name = "DevOpsPublicKey" }

data "aws_ssm_parameter" "ec2_key_name" {  name = "/kuflink/${var.environment}/ec2_key_name" }
data "aws_ssm_parameter" "build_notification_email" { name = "/kuflink/${var.environment}/build_notification_email"}
data "aws_ssm_parameter" "ops_notification_email" {  name = "/kuflink/${var.environment}/ops_notification_email"}


output "global" {
  description = "Global/shared parameters from global.tf"
  value = {
    # Account Information
    account_id   = data.aws_ssm_parameter.account_id.value
    canonical_id = data.aws_ssm_parameter.canonical_id.value
    
    # SSH Keys
    team_lead_public_key   = data.aws_ssm_parameter.TeamLeadPublicKey.value
    devops_public_key      = data.aws_ssm_parameter.DevOpsPublicKey.value
    
    # EC2
    ec2_key_name = data.aws_ssm_parameter.ec2_key_name.value
        
    # Notifications
    build_notification_email = data.aws_ssm_parameter.build_notification_email.value
    ops_notification_email   = data.aws_ssm_parameter.ops_notification_email.value
  }
  sensitive = true
}



