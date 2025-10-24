# alb.tf

# Target Group for dbt docs
resource "aws_lb_target_group" "dbt_docs" {
  name     = "${var.dbt_name}-docs-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "${var.dbt_name}-docs-target-group"
  }
}

# Attach EC2 instance to target group
resource "aws_lb_target_group_attachment" "dbt_docs" {
  target_group_arn = aws_lb_target_group.dbt_docs.arn
  target_id        = aws_instance.dbt_host.id
  port             = 8080
}

# Application Load Balancer
resource "aws_lb" "dbt_docs" {
  name               = "${var.dbt_name}-docs-alb"
  internal           = false # public-facing
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids # must be in at least 2 AZs

  enable_deletion_protection = false

  tags = {
    Name = "${var.dbt_name}-docs-alb"
  }
}

resource "aws_lb_listener" "dbt_docs_https" {
  load_balancer_arn = aws_lb.dbt_docs.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dbt_docs.arn
  }
}

# Redirect HTTP to HTTPS
resource "aws_lb_listener" "dbt_docs_http_redirect" {
  load_balancer_arn = aws_lb.dbt_docs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
