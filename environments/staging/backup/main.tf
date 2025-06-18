# Reference networking outputs (if needed later)
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/networking/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}

# Reference database outputs
data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/database/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}

# Reference compute outputs
data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/compute/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}

# Reference IAM outputs 
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/iam/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}

# Call Backup Module
module "backup-terraform" {
  source = "../../../modules/backup"

  backup_vault_name         = "kuflink-test-backup-vault"
  backup_plan_name          = "kuflink-test-backup-plan"

  # Now pass from remote state
  backup_service_role_arn   = data.terraform_remote_state.iam.outputs.backup_role_arn

  rds_instance_arn          = data.terraform_remote_state.database.outputs.db_instance_arn
  ec2_instance_arn          = data.terraform_remote_state.compute.outputs.test_instance_arn

  environment               = "test"
}
