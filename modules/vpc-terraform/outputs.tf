output "vpc_id" {
  value = aws_vpc.test_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id,
    aws_subnet.public_subnet_c.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id,
    aws_subnet.private_subnet_c.id
  ]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = try(aws_nat_gateway.nat_gw[0].id, null)
}

output "nat_gateway_public_ip" {
  value = try(aws_eip.nat_eip[0].public_ip, null)
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

