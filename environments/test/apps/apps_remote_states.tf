# Apps layer trying to reference foundation outputs
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "kuflink-test-states"
    key    = "test/foundation/terraform.tfstate"
    region = "eu-west-2"
  }
}

# Apps layer trying to reference data outputs
data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    bucket = "kuflink-test-states"
    key    = "test/data/terraform.tfstate"
    region = "eu-west-2"
  }
}

# Apps layer trying to reference platform outputs
data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = "kuflink-test-states"
    key    = "test/platform/terraform.tfstate"
    region = "eu-west-2"
  }
}