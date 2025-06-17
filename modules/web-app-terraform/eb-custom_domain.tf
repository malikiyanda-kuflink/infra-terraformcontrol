# Route 53 Hosted Zone for brickfin.co.uk
data "aws_route53_zone" "brickfin" {
  name         = "brickfin.co.uk."
  private_zone = false
}

# Create a CNAME record for p2papi.brickfin.co.uk
resource "aws_route53_record" "p2papi_cname" {
  zone_id = data.aws_route53_zone.brickfin.zone_id
  name    = "p2p-test.brickfin.co.uk"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elastic_beanstalk_environment.kuflink_env.endpoint_url]
}