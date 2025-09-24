data "aws_ssm_parameter" "metabase_ami" { name = "/ec2/metabase/ami_id" }
data "aws_ssm_parameter" "metabase_instance_type" { name = "/ec2/metabase/instance_type" }