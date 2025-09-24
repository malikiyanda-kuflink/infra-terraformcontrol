# ---------------------------------------------------------------#
# WORDPRESS PARAMETERS
# ---------------------------------------------------------------#
data "aws_ssm_parameter" "TeamLeadPublicKey" { name = "TeamLeadPublicKey" }
data "aws_ssm_parameter" "DevOpsPublicKey" { name = "DevOpsPublicKey" }

data "aws_ssm_parameter" "DevOpsKeyPair" { name = "/ec2/default_devopskey" }
data "aws_ssm_parameter" "StagingsKeyPair" { name = "/ec2/default_stagingkey" }
data "aws_ssm_parameter" "DefaultAMI_ID" { name = "/ec2/default_ubuntu_ami" }
data "aws_ssm_parameter" "DefaultInstanceType" { name = "/ec2/default_instance_type" }
data "aws_ssm_parameter" "office_ip" { name = "/ec2/default_ssh_office" }
data "aws_ssm_parameter" "ssl_cert" { name = "/ec2/default_acm_wordpress_ssl" }
