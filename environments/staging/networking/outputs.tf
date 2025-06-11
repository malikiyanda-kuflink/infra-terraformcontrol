output "vpc_id" {
  value = module.vpc-terraform.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc-terraform.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc-terraform.private_subnet_ids
}

output "internet_gateway_id" {
  value = module.vpc-terraform.internet_gateway_id
}

output "nat_gateway_id" {
  value = module.vpc-terraform.nat_gateway_id
}

output "nat_gateway_public_ip" {
  value = module.vpc-terraform.nat_gateway_public_ip
}


