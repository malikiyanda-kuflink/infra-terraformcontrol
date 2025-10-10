terraform {
  backend "s3" {
    bucket         = "kuflink-test-states"
    key            = "test/foundation/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "kuflink-tf-locks-test"
    encrypt        = true
  }
}