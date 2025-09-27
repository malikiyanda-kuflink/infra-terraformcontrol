# Route 53 Hosted Zone
data "aws_route53_zone" "brickfin" {
  name         = local.aws_route53_zone 
  private_zone = false
}

resource "aws_route53_record" "p2papi_cname" {
  count = local.enable_eb ? 1 : 0

  zone_id = data.aws_route53_zone.brickfin.zone_id
  name    = data.terraform_remote_state.foundation.outputs.api_domain
  type    = "CNAME"
  ttl     = 300

  # Index the module because it has count
  records = [module.eb-api[0].web_env_cname]
}


resource "aws_route53_record" "frontend_alias" {
  count   = local.enable_s3_frontend ? 1 : 0
  zone_id = local.frontend_hosted_zone_id
  name    = local.frontend_record_name 
  type    = "A"

  alias {
    name                   = module.s3-frontend.cloudfront_domain_name
    zone_id                = local.cloudfront_zone_id 
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "admin_alias" {
  count   = local.enable_s3_admin ? 1 : 0
  zone_id = local.admin_hosted_zone_id
  name    = local.admin_record_name 
  type    = "A"

  alias {
    name                   = module.s3-admin.cloudfront_domain_name
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }
}

