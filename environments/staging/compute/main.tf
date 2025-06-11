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



