terraform {
  backend "s3" {
    bucket         = "kuflink-staging-state"
    key            = "staging/shared/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}
