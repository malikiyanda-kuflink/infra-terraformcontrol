resource "aws_route53_record" "db_proxy" {
  count = (local.enable_bastion && local.enable_bastion_dns) ? 1 : 0

  zone_id = local.hosted_zone_id
  name    = local.staging_dns_bastion_name
  type    = "A"
  ttl     = 60
  records = [local.bastion_eip_public_ip]
}

module "ec2-bastion" {
  count                         = local.enable_bastion ? 1 : 0
  source                        = "../../../modules/ec2-bastion"
  vpc_id                        = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  public_subnet_id              = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.public_ids[0]
  bastion_sg_id                 = aws_security_group.bastion_sg.id
  bastion_instance_profile_name = data.terraform_remote_state.foundation.outputs.iam_resources.bastion.instance_profile_name

  ssh_key_name            = data.terraform_remote_state.foundation.outputs.global.ec2_key_name
  instance_type           = "t3.micro"
  bastion_ami_id          = data.terraform_remote_state.foundation.outputs.ec2_bastion.ami_id
  bastion_elastic_ip_name = "${local.name_prefix}-bastion-ec2-eip"
  bastion_user_data       = file("${path.root}/user-data/bastion_user_data.sh")
  bastion_name            = "Kuflink-Test-Bastion"

  instance_tags = {
    DB_HOST      = local.staging_dns_bastion_target
    FORWARD_PORT = local.forward_port
    TARGET_PORT  = local.target_port
  }

}