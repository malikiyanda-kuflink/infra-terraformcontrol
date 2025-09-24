# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id            = aws_vpc.test_vpc.id
#   service_name      = "com.amazonaws.${var.aws_region}.ssm"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [
#     aws_subnet.public_subnet_a.id,
#     aws_subnet.public_subnet_b.id,
#     aws_subnet.public_subnet_c.id
#   ]
#   security_group_ids = [var.ssm_endpoints_sg_id]

#   private_dns_enabled = true

#   tags = {
#     Name      = "SSM Endpoint"
#     ManagedBy = "Terraform"
#   }
# }

# resource "aws_vpc_endpoint" "ssmmessages" {
#   vpc_id            = aws_vpc.test_vpc.id
#   service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [
#     aws_subnet.public_subnet_a.id,
#     aws_subnet.public_subnet_b.id,
#     aws_subnet.public_subnet_c.id
#   ]
#   security_group_ids = [var.ssm_endpoints_sg_id]

#   private_dns_enabled = true

#   tags = {
#     Name      = "SSM Messages Endpoint"
#     ManagedBy = "Terraform"
#   }
# }

# resource "aws_vpc_endpoint" "ec2messages" {
#   vpc_id            = aws_vpc.test_vpc.id
#   service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [
#     aws_subnet.public_subnet_a.id,
#     aws_subnet.public_subnet_b.id,
#     aws_subnet.public_subnet_c.id
#   ]
#   security_group_ids = [var.ssm_endpoints_sg_id]

#   private_dns_enabled = true

#   tags = {
#     Name      = "EC2 Messages Endpoint"
#     ManagedBy = "Terraform"
#   }
# }
