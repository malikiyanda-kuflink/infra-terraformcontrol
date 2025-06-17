# Reference networking outputs
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/networking/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/shared/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}

# Reference IAM outputs → this is the new part
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/iam/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}


# Call bastion module
module "bastion-terraform" {
  source = "../../../modules/bastion-terraform"

  vpc_id                  = data.terraform_remote_state.networking.outputs.vpc_id
  public_subnet_id        = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]
  office_ip_cidr_blocks   = var.office_ip_cidr_blocks
  ssh_key_parameter_name  = var.ssh_key_parameter_name 
  ssh_key_name            = "staging"
  bastion_name            = "Kuflink-Test-Bastion"
} 


module "ec2_test_instance" {
  source              = "../../../modules/ec2-test-terraform"

  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_id   = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
  bastion_sg_id       = module.bastion-terraform.bastion_sg_id
  ssh_key_name        = "staging"
  instance_name       = "Kuflink-Test-Instance"
  # No instance_type → will use default "t2.micro"
  # instance_type       = "t3.micro"  # override the default here
}

module "redis_elastic_cache" {
  source = "../../../modules/redis-elastic-cache"
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id


  private_subnet_ids           = data.terraform_remote_state.networking.outputs.private_subnet_ids
  redis_elastic_cache_password = data.terraform_remote_state.shared.outputs.redis_elastic_cache_password

  web_app_sg_id  = module.web_app.web_app_sg_id 
  bastion_sg_id = module.bastion-terraform.bastion_sg_id
}



module "web_app" { 
  source = "../../../modules/web-app-terraform"

  eb_role_arn             = data.terraform_remote_state.iam.outputs.eb_role_arn
  eb_instance_profile_arn = data.terraform_remote_state.iam.outputs.eb_instance_profile_arn
 
  # Networking
  vpc_id                  = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids  = data.terraform_remote_state.networking.outputs.private_subnet_ids  
  public_subnet_ids   = data.terraform_remote_state.networking.outputs.public_subnet_ids
  # elb_security_group_id = module.networking.alb_sg_id
  # eb_ssh_sg_id        = module.iam.eb_instance_sg_id   
  # ssl_certificate_arn = data.terraform_remote_state.shared.outputs.ssl_cert_arn 
    # SSL
  ssl_certificate_arn = var.ssl_certificate_arn
  # Secrets from shared 
  # db_test_username     = data.terraform_remote_state.shared.outputs.db_test_username
  # db_test_password     = data.terraform_remote_state.shared.outputs.db_test_password
  # db_test_host         = data.terraform_remote_state.shared.outputs.db_test_host
  # redis_password       = data.terraform_remote_state.shared.outputs.redis_elastic_cache_password 
  mandrill_secret      = data.terraform_remote_state.shared.outputs.mandrill_secret
  bank_of_england_api_url = data.terraform_remote_state.shared.outputs.bank_of_england_api_url
  # app_key              = data.terraform_remote_state.shared.outputs.app_key 

  # redis_elastic_cache_password = data.terraform_remote_state.shared.outputs.redis_elastic_cache_password

  # App configuration
  # app_env              = var.app_env 
  # app_url              = var.app_url
  environment          = var.environment
} 




