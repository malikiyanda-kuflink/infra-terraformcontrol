# NAT (optional)
resource "aws_eip" "nat_eip" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0
  tags  = merge(var.tags, { Name = "${var.vpc_name}-nat-eip" })
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public["a"].id
  tags          = merge(var.tags, { Name = "${var.vpc_name}-nat-gw" })
}