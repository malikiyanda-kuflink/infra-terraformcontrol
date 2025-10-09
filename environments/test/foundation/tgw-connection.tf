#########################################################
# TEST TERRAFORM SCRIPT
# File: test/tgw-connection.tf
#
# This script connects the test VPC to the existing TGW
# created by the staging environment.
#
# Prerequisites:
# - Staging Terraform must be deployed first
# - TGW and VPN connection must exist
# - Test VPC must exist 
#########################################################

###########################################################
# Find Existing TGW from Staging
###########################################################
data "aws_ec2_transit_gateway" "existing_tgw" {
  filter {
    name   = "tag:Name"
    values = ["kuflink-core-tgw"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ec2_transit_gateway_route_table" "existing_route_table" {
  filter {
    name   = "tag:Name"
    values = ["tgw-rt-main"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [data.aws_ec2_transit_gateway.existing_tgw.id]
  }
}

# Alternative: Use remote state instead of data sources
# Uncomment this section if you prefer remote state lookup
/*
data "terraform_remote_state" "staging" {
  backend = "s3"  # or whatever backend you use
  
  config = {
    bucket = "your-terraform-state-bucket"
    key    = "staging/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Then reference like: data.terraform_remote_state.staging.outputs.transit_gateway_id
*/

###########################################################
# Test VPC Data Sources
###########################################################

# # Reference your existing test VPC
# data "aws_vpc" "test" {
#   tags = {
#     Name = "Kuflink-Test-VPC"  # Adjust to match your test VPC name
#   }
# }

# # Get private subnets from test VPC
# data "aws_subnets" "test_private" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.test.id]
#   }

#   tags = {
#     Type = "Private"  # Adjust based on your subnet tagging
#   }
# }

# # Get private route tables from test VPC
# data "aws_route_tables" "test_private" {
#   vpc_id = data.aws_vpc.test.id

#   tags = {
#     Type = "Private"  # Adjust based on your route table tagging
#   }
# }

###########################################################
# Test VPC Attachment to TGW
###########################################################
resource "aws_ec2_transit_gateway_vpc_attachment" "test" {
  subnet_ids         = module.vpc.private_subnet_ids
  transit_gateway_id = data.aws_ec2_transit_gateway.existing_tgw.id
  vpc_id             = module.vpc.vpc_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name        = "test-vpc-to-tgw"
    Environment = "test"
    Purpose     = "tgw-connectivity"
  }
}

############################################################
# Associate with TGW Route Table
############################################################
resource "aws_ec2_transit_gateway_route_table_association" "test_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.test.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.existing_route_table.id
  replace_existing_association   = true
}

# Optional: Propagation for Test VPC
resource "aws_ec2_transit_gateway_route_table_propagation" "test_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.test.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.existing_route_table.id
}

###############################################################
# TGW Route for Test VPC
###############################################################
resource "aws_ec2_transit_gateway_route" "to_test_vpc" {
  destination_cidr_block         = module.vpc.vpc_cidr_block
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.existing_route_table.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.test.id
}



###############################################################
# Variables
###############################################################
###########################################################
# Read Shared Configuration from SSM
###########################################################
data "aws_ssm_parameter" "onprem_cidrs" {
  name = "/kuflink/network/onprem_cidrs"
}

data "aws_ssm_parameter" "staging_vpc_cidr" {
  name = "/kuflink/network/staging_vpc_cidr"
}

locals {
  onprem_cidrs     = jsondecode(data.aws_ssm_parameter.onprem_cidrs.value)
  staging_vpc_cidr = data.aws_ssm_parameter.staging_vpc_cidr.value
}

###################################################################
# Use the SSM values in routes
###################################################################
resource "aws_route" "test_to_onprem" {
  route_table_id         = module.vpc.private_rt_id
  destination_cidr_block = local.onprem_cidrs[0] # From SSM
  transit_gateway_id     = data.aws_ec2_transit_gateway.existing_tgw.id
}

resource "aws_route" "test_to_staging" {
  route_table_id         = module.vpc.private_rt_id
  destination_cidr_block = local.staging_vpc_cidr # From SSM
  transit_gateway_id     = data.aws_ec2_transit_gateway.existing_tgw.id
}

# Remove the variables entirely from tests

###############################################################
# Outputs
###############################################################
output "test_vpc_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.test.id
}

output "connected_tgw_id" {
  value = data.aws_ec2_transit_gateway.existing_tgw.id
}
