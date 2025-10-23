module "ec2-dbt" {
  count       = local.enable_dbt ? 1 : 0
  source      = "../../../modules/ec2-dbt"
  name_prefix = local.name_prefix
  environment = local.environment

  # Networking
  vpc_id            = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  private_subnet_id = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.private_ids[2]
  public_subnet_ids = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.public_ids

  # Security
  dbt_sg_id                 = aws_security_group.dbt_sg.id
  alb_sg_id                 = aws_security_group.dbt_alb_sg.id
  dbt_instance_profile_name = data.terraform_remote_state.foundation.outputs.iam_resources.dbt.instance_profile_name
  acm_certificate_arn       = data.terraform_remote_state.foundation.outputs.ssl_certificate_arn

  # DNS
  dbt_docs_subdomain = local.dbt_config.dbt_docs_subdomain

  # Instance Configuration
  ssh_key_name  = local.dbt_config.ssh_key_name
  instance_type = local.dbt_config.instance_type
  dbt_user_data = local.dbt_user_data_with_env
  canonical_id  = data.terraform_remote_state.foundation.outputs.global.canonical_id
  dbt_name      = local.dbt_config.dbt_name

  #Code Deploy Configuration
  code_deploy_project_name    = local.dbt_config.code_deploy_project_name
  codedeploy_service_role_arn = data.terraform_remote_state.foundation.outputs.iam_resources.code_deploy.role_arn

  instance_tags = {
    DBT-Test-DeploymentTarget = local.dbt_config.code_deploy_project_name
  }

}