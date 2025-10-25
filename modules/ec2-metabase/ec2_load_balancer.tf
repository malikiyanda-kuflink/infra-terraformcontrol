# Data source to get the ACM certificate
data "aws_acm_certificate" "imported_cert_ec2" {
  domain      = var.aws_route53_zone
  statuses    = ["ISSUED"]
  most_recent = true
}


# Load Balancer
resource "aws_lb" "ec2_alb" {
  name               = "kuflink-test-metabase-ec2-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.metabase_alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "kuflink-metabase-ec2-alb"
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.ec2_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  certificate_arn = data.aws_acm_certificate.imported_cert_ec2.arn

  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
  # }

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Default listener rule active"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "metabase_forward" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  depends_on = [aws_lb_target_group.ec2_lb_tg]
}



# HTTP Listener for Redirect
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ec2_alb.arn
  port              = 80
  protocol          = "HTTP"

  lifecycle {
    create_before_destroy = true
  }
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Target Group for Nginx
resource "aws_lb_target_group" "ec2_lb_tg" {
  name        = "test-metabase-ec2-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "ec2_tg_attachment" {
  target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
  target_id        = aws_instance.kuflink_ec2.id
  port             = 3000
} 