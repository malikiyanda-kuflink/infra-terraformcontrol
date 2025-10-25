# route53.tf

# Get the hosted zone for route53 zone
data "aws_route53_zone" "route53_zone_name" {
  name         = var.route53_zone_name
  private_zone = false
}

# Create DNS record for dbt docs
resource "aws_route53_record" "dbt_docs" {
  zone_id = data.aws_route53_zone.route53_zone_name.zone_id
  name    = var.dbt_docs_subdomain
  type    = "A"

  alias {
    name                   = aws_lb.dbt_docs.dns_name
    zone_id                = aws_lb.dbt_docs.zone_id
    evaluate_target_health = true
  }
}