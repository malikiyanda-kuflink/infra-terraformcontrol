# Get the existing Route 53 hosted zone
data "aws_route53_zone" "kuflink_zone" {
  name         = var.aws_route53_zone # Ensure you include the trailing dot
  private_zone = false             # Set to true if it's a private hosted zone
}


resource "aws_route53_record" "brickfin_root" {
  zone_id = data.aws_route53_zone.kuflink_zone.zone_id
  name    = "brickfin.co.uk"
  type    = "A"

  alias {
    name                   = aws_lb.ec2_alb.dns_name
    zone_id                = aws_lb.ec2_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "brickfin_www" {
  zone_id = data.aws_route53_zone.kuflink_zone.zone_id
  name    = "www.brickfin.co.uk"
  type    = "A"

  alias {
    name                   = aws_lb.ec2_alb.dns_name
    zone_id                = aws_lb.ec2_alb.zone_id
    evaluate_target_health = true
  }
}
