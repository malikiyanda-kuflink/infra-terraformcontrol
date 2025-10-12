# --- Single NAT in public subnet A ---
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.vpc_name}-nat-eip" })
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public["a"].id
  tags          = merge(var.tags, { Name = "${var.vpc_name}-nat-gw" })
  depends_on    = [aws_internet_gateway.igw]
}