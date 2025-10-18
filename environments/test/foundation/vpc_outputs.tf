# vpc-outputs.tf

output "vpc_resources" {
  description = "All VPC networking resources grouped"
  value = {
    # VPC Core
    vpc = {
      id         = module.vpc.vpc_id
      cidr_block = module.vpc.vpc_cidr_block
    }

    # Gateways
    gateways = {
      internet_gateway_id   = module.vpc.internet_gateway_id
      nat_gateway_id        = module.vpc.nat_gateway_id
      nat_gateway_public_ip = module.vpc.nat_gateway_public_ip
    }

    # Subnets
    subnets = {
      public_ids    = module.vpc.public_subnet_ids
      private_ids   = module.vpc.private_subnet_ids
      private_cidrs = module.vpc.private_subnet_cidrs
    }

    # Route Tables
    route_tables = {
      private_rt_id = module.vpc.private_rt_id
    }

    # Transit Gateway Attachment
    transit_gateway = {
      test_vpc_attachment_id = aws_ec2_transit_gateway_vpc_attachment.test.id
      connected_tgw_id       = data.aws_ec2_transit_gateway.existing_tgw.id
    }
  }
  sensitive = false
}

# output "test_vpc_attachment_id" {
#   value = aws_ec2_transit_gateway_vpc_attachment.test.id
# }

# output "connected_tgw_id" {
#   value = data.aws_ec2_transit_gateway.existing_tgw.id
# }
