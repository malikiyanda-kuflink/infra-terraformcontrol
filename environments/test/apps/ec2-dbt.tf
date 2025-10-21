module "ec2-dbt" {
  count                     = local.enable_dbt ? 1 : 0
  source                    = "../../../modules/ec2-dbt"
  
  # Networking
  vpc_id                      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  private_subnet_id           = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.private_ids[2]
  public_subnet_ids           = data.terraform_remote_state.networking.outputs.public_subnet_ids
  
  # Security
  dbt_sg_id                 = data.terraform_remote_state.data.outputs.dbt_sg_id  # FIX THIS
  dbt_instance_profile_name = data.terraform_remote_state.foundation.outputs.iam_resources.dbt.instance_profile_name
  acm_certificate_arn       = data.terraform_remote_state.shared.outputs.brickfin_ssl_acm
  
  # DNS
  dbt_docs_subdomain = local.dbt_config.dbt_docs_subdomain
  
  # Instance Configuration
  ssh_key_name  = local.dbt_config.ssh_key_name
  instance_type = local.dbt_config.instance_type
  dbt_user_data = base64encode(local.dbt_user_data)
  canonical_id  = data.terraform_remote_state.foundation.outputs.canonical_id
  dbt_name      = local.dbt_config.dbt_name
}