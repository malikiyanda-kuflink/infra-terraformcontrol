terraform {
  backend "s3" {
    bucket         = "kuflink-staging-state"
    key            = "staging/networking/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}
