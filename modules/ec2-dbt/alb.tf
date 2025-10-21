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
  internal           = false  # public-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids  # must be in at least 2 AZs

  enable_deletion_protection = false

  tags = {
    Name = "${var.dbt_name}-docs-alb"
  }
}

# # ALB Listener (HTTP)
# resource "aws_lb_listener" "dbt_docs_http" {
#   load_balancer_arn = aws_lb.dbt_docs.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.dbt_docs.arn
#   }
# }


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

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.dbt_name}-alb-sg"
  description = "Security group for dbt docs ALB"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP from anywhere
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Allow inbound HTTPS from anywhere
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.dbt_name}-alb-sg"
  }
}

# Update EC2 security group to allow traffic from ALB
resource "aws_security_group_rule" "dbt_from_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = var.dbt_sg_id
}

