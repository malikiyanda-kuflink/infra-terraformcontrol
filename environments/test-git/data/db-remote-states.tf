# Platform layer trying to reference foundation outputs
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "kuflink-test-states"
    key    = "test-git/foundation/terraform.tfstate" 
    region = "eu-west-2"
  }
}