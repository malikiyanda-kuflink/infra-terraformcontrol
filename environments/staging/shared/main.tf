data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/compute/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}


module "secrets" {
  source     = "../../../modules/secrets-manager-terraform"
} 
