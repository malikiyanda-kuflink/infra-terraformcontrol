# ---------------------------------------------------------------#
# Public Key SSM Parameters for SSH Access 
# ---------------------------------------------------------------#
data "aws_ssm_parameter" "ssh_key_parameter_name" { name = "DevOpsPublicKey" }