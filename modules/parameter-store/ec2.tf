# ===================================================================
# METABASE EC2 PARAMETERS
# ===================================================================
data "aws_ssm_parameter" "metabase_ami" { name = "/ec2/${var.environment}/metabase_ami_id" }
data "aws_ssm_parameter" "metabase_instance_type" { name = "/ec2/${var.environment}/metabase_instance_type" }

output "ec2_metabase" {
  description = "Metabase EC2 parameters from ec2_metabase.tf"
  value = {
    ami_id        = data.aws_ssm_parameter.metabase_ami.value
    instance_type = data.aws_ssm_parameter.metabase_instance_type.value
  }
  sensitive = true
}