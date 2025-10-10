module "ec2-redis" {
  count                       = local.enable_redis ? 1 : 0
  source                      = "../../../modules/ec2-redis"
  vpc_id                      = data.terraform_remote_state.foundation.outputs.vpc_id
  private_subnet_id           = data.terraform_remote_state.foundation.outputs.private_subnet_ids[2]
  redis_sg_id                 = aws_security_group.redis_sg.id
  redis_instance_profile_name = data.terraform_remote_state.foundation.outputs.redis_ec2_instance_profile_name
  redis_host_param_name       = local.redis_host_param_name

  ssh_key_parameter_name = data.terraform_remote_state.foundation.outputs.ssh_key_parameter_name

  ssh_key_name                      = data.terraform_remote_state.foundation.outputs.ec2_key_name
  instance_type                     = "t3.micro"
  redis_ami_id                      = data.terraform_remote_state.foundation.outputs.redis_ami_id
  associate_public_ip_address       = false
  redis_user_data_replace_on_change = false
  redis_user_data                   = file("${path.root}/user-data/redis_user_data.sh")
  redis_name                        = "Kuflink-Test-Redis"

}