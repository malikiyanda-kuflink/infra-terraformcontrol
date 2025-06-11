terraform {
  backend "s3" {
    bucket         = "kuflink-staging-state"
    key            = "staging/backup/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}
