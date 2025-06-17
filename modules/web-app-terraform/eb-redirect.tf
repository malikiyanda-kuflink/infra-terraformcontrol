data "aws_lb_listener" "http_listener" {
  load_balancer_arn = element(tolist(aws_elastic_beanstalk_environment.kuflink_env.load_balancers), 0)
  port              = 80
  depends_on        = [aws_elastic_beanstalk_environment.kuflink_env]
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
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}