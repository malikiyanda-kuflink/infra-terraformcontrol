resource "aws_security_group" "redis_sg" {
  name        = "Kuflink-Terraform-Redis-SG"
  description = "Allow Redis traffic"
  vpc_id      = var.vpc_id

ingress {
  description     = "Allow Redis from EB web app"
  from_port       = 6379
  to_port         = 6379
  protocol        = "tcp"
  security_groups = [var.web_app_sg_id]
}


ingress {
    description     = "Allow SSH from Bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
}

  ingress {
    description = "Allow SSH from Office IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [        # Restrict access to specific IPs
      "89.197.135.242/32", # Office IP

    ]
  }

egress {
description = "everywhere IP"
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
}

  tags = {
    Descriptpion = "Redis Security Group for laravel-php-api"      
    }
  
}
