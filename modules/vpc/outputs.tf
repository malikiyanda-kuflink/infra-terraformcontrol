
output "vpc_id" { value = aws_vpc.vpc.id }
output "public_subnet_ids" { value = [for s in aws_subnet.public : s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }
output "internet_gateway_id" { value = aws_internet_gateway.igw.id }
output "nat_gateway_id" { value = try(aws_nat_gateway.nat_gw.id, null) }
output "nat_gateway_public_ip" { value = try(aws_eip.nat_eip.public_ip, null) }
output "vpc_cidr_block" { value = aws_vpc.vpc.cidr_block }
output "private_rt_id" { value = aws_route_table.private_rt.id }

# Simple list of private subnet CIDRs
output "private_subnet_cidrs" { value = [for s in aws_subnet.private : s.cidr_block] }