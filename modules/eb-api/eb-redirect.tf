# Provide the EB env name you deploy (string, not from a resource output)
# variable "eb_env_name" { type = string }

data "aws_lb" "eb_alb" {
  depends_on = [aws_elastic_beanstalk_environment.web_env]
  tags = {
    "elasticbeanstalk:environment-name" = var.eb_web_environment_name
  }
  # Optional extra guard:
  # name = "awseb--${var.eb_env_name}"  # only if your naming is predictable
}

data "aws_lb_listener" "http_listener" {
  load_balancer_arn = data.aws_lb.eb_alb.arn
  port              = 80
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = data.aws_lb_listener.http_listener.arn
  priority     = 1

  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }

  }

  condition {
    path_pattern { values = ["/*"] }
  }

  # lifecycle {
  #   create_before_destroy = true
  # }
}
