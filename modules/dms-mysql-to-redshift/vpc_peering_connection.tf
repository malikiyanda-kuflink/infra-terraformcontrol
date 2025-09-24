# resource "aws_vpc_peering_connection" "default_to_kuflink" {
#   vpc_id        = var.vpc_default_id
#   peer_vpc_id   = var.vpc_id
#   auto_accept   = true

#   tags = {
#     Name = "default-to-kuflink-test"
#   }
# }

# # Default VPC → Route to Custom VPC (RDS)

# resource "aws_route" "default_to_kuflink" {
#   route_table_id         = "rtb-de957ab5"
#   destination_cidr_block = var.vpc_cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.default_to_kuflink.id
# }


# # Custom VPC → Route to Default VPC (DMS)
# resource "aws_route" "kuflink_to_default" {
#   route_table_id         = var.private_route_table_id
#   destination_cidr_block = "172.31.0.0/16"
#   vpc_peering_connection_id = aws_vpc_peering_connection.default_to_kuflink.id
# }
