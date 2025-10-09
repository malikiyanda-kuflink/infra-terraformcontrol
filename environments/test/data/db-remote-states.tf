# Platform layer trying to reference foundation output
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "kuflink-test-states"
    key    = "test/foundation/terraform.tfstate"
    region = "eu-west-2"
  }
}