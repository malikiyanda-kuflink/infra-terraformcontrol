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



module "rds" {
  source = "../../../modules/rds-terraform"

#   db_test_username            = module.secrets_manager.db_test_username
#   db_test_password            = module.secrets_manager.db_test_password
#   db_test_database            = module.secrets_manager.db_test_database
#   db_test_name_identifier     = module.secrets_manager.db_test_name_identifier

  db_test_username            = var.db_test_username
  db_test_password            = var.db_test_password
  db_test_database            = var.db_test_database 
  db_test_name_identifier     = var.db_test_name_identifier
  db_test_snapshot_identifier = var.db_test_snapshot_identifier

  vpc_id                      = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids 
  db_parameter_group_name     = var.db_parameter_group_name 
  db_subnet_group_name        = var.db_subnet_group_name
  rds_name_tag                = var.rds_name_tag
  rds_allowed_cidr_blocks     = var.rds_allowed_cidr_blocks 
  environment                 = var.environment  
  restore_from_snapshot       = var.restore_from_snapshot 
allocated_storage                     = var.allocated_storage
storage_type                          = var.storage_type
engine                                = var.engine
engine_version                        = var.engine_version
instance_class                        = var.instance_class 
backup_retention_period               = var.backup_retention_period
skip_final_snapshot                   = var.skip_final_snapshot
auto_minor_version_upgrade            = var.auto_minor_version_upgrade
publicly_accessible                   = var.publicly_accessible
deletion_protection                   = var.deletion_protection
multi_az                              = var.multi_az
iam_database_authentication_enabled   = var.iam_database_authentication_enabled
storage_encrypted                     = var.storage_encrypted


}