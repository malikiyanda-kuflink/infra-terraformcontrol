resource "aws_security_group" "ec2_alb_sg" {
  name        = "kuflink-test-wp-ec2-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  # Ingress rules for HTTP and HTTPS traffic
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules - allowing all outbound traffic by default
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Kuflink-Test-WP-EC2-ALB-SG"
  }
}