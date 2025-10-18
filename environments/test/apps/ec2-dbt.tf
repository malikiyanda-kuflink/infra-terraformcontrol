module "ec2-dbt" {
  count                     = local.enable_dbt ? 1 : 0
  source                    = "../../../modules/ec2-dbt"
  vpc_id                    = data.terraform_remote_state.foundation.outputs.vpc_id
  private_subnet_id         = data.terraform_remote_state.foundation.outputs.private_subnet_ids[2]
  dbt_sg_id                 = data.terraform_remote_state.data.outputs.dbt_sg_id
  dbt_instance_profile_name = data.terraform_remote_state.foundation.outputs.dbt_ec2_instance_profile_name


  ssh_key_name  = data.terraform_remote_state.foundation.outputs.ec2_key_name
  instance_type = "t3.medium"
  dbt_user_data = file("${path.root}/user-data/dbt_user_data.sh")
  canonical_id  = data.terraform_remote_state.foundation.outputs.canonical_id
  dbt_name      = "Kuflink-Test-DBT"
}