# route53.tf

# Get the hosted zone for brickfin.co.uk
data "aws_route53_zone" "brickfin" {
  name         = "brickfin.co.uk"
  private_zone = false
}

# Create DNS record for dbt docs
resource "aws_route53_record" "dbt_docs" {
  zone_id = data.aws_route53_zone.brickfin.zone_id
  name    = var.dbt_docs_subdomain
  type    = "A"

  alias {
    name                   = aws_lb.dbt_docs.dns_name
    zone_id                = aws_lb.dbt_docs.zone_id
    evaluate_target_health = true
  }
}