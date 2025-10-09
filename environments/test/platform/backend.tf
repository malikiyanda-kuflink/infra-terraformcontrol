# environments/test/platform/backend.tf
terraform {
  backend "s3" {
    # Config provided via -backend-config during init
  }
}