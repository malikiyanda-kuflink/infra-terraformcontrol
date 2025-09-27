# =======================================
# Comptue layer  
# =======================================
locals {
  env                    = "test"
  name_prefix            = "kuflink-test"
  
  environment            = "Test"
  name_prefix_upper      = "Kuflink-Test"

aws_route53_zone       = data.terraform_remote_state.foundation.outputs.aws_route53_zone
staging_hosted_zone_id = data.terraform_remote_state.foundation.outputs.staging_hosted_zone_id
cloudfront_zone_id     = data.terraform_remote_state.foundation.outputs.cloudfront_zone_id
}
