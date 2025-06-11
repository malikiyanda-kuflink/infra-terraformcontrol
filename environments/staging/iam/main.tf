module "iam_terraform" {
  source = "../../../modules/iam-terraform"

  backup_role_name             = "kuflink-test-backup-role"
  ec2_test_instance_role_name  = "kuflink-test-ec2-test-role"
  lambda_role_name              = "kuflink-test-lambda-role"

  tags = {
    Environment = "test" 
    Owner       = "Kuflink"
  }
}
