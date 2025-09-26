#########################################################
# Site‑to‑Site VPN — Kuflink Test 
# File: site-to-site-vpn.tf
#
# Purpose / Traffic flow (static routing):
#
#   On‑Prem (DrayTek, public IP = var.onprem_public_ip)
#        ⇅  IPsec (2 tunnels)
#   AWS VPN Connection  ──(VPN attachment)──► TGW (core_tgw)
#        ⇅                                   │
#   TGW Route Table (tgw-rt-onprem)          │
#     - 10.0.0.0/16  → VPC attachment        │
#     - <onprem CIDR> → VPN attachment       │
#                                             ▼
#   VPC: 10.0.0.0/16 — Private subnets have a route
#   to <onprem CIDR> via TGW. Security Groups/NACLs
#   must allow the traffic on both sides.
#
# Notes:
# - We pin IKE/ESP proposals to match security policy.
# - Static routing (no BGP) → TGW + VPC routes are explicit.
# - Two tunnels are provisioned; configure both on DrayTek.
#########################################################

############################
# 1) Transit Gateway (core)
############################
# Regional router that connects multiple networks:
#   - VPN attachment (to on‑prem)
#   - VPC attachment (to Kuflink testuction VPC)
resource "aws_ec2_transit_gateway" "core_tgw" {
  description = "Core TGW for on-prem connectivity"
  tags = { Name = "core-tgw" }
}

#############################################
# 2) TGW Route Table dedicated to on‑prem
#############################################
# Holds the forwarding rules between the VPN attachment
# and the VPC attachment. We keep this separate from the
# default TGW RT for least surprise / clear intent.
resource "aws_ec2_transit_gateway_route_table" "onprem" {
  transit_gateway_id = aws_ec2_transit_gateway.core_tgw.id
  tags = { Name= "tgw-rt-onprem" }
}

#############################################
# 3) Customer Gateway (represents on‑prem end)
#############################################
# Static routing → bgp_asn is ignored by AWS, but the
# Terraform provider requires a value. We use 65000.
resource "aws_customer_gateway" "onprem" {
  bgp_asn    = 65000
  ip_address = var.onprem_public_ip   # static public IP of DrayTek
  type       = "ipsec.1"
  tags = {Name= "kuflink-onprem-cgw"}
}

#########################################
# 4) VPN Connection (two IPsec tunnels)
#########################################
# - Attaches the CGW to the TGW.
# - Static routes only (no BGP).
# - IKE/ESP proposals pinned to security team policy.
resource "aws_vpn_connection" "onprem_to_tgw" {
  transit_gateway_id  = aws_ec2_transit_gateway.core_tgw.id
  customer_gateway_id = aws_customer_gateway.onprem.id
  type                = "ipsec.1"
  static_routes_only  = true

  # IKE version
  tunnel1_ike_versions = ["ikev2"]
  tunnel2_ike_versions = ["ikev2"]

  # ---- Phase 1 (IKE SA) ----
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers      = [14]         # or 19 if you prefer ECC
  tunnel2_phase1_dh_group_numbers      = [14]
  tunnel1_phase1_lifetime_seconds      = 28800
  tunnel2_phase1_lifetime_seconds      = 28800

  # ---- Phase 2 (IPsec / Child SA) ----
  # If you want AES-GCM (preferred), set AES256-GCM-16 and remove integrity.
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA2-256"] # omit if using GCM
  tunnel2_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase2_dh_group_numbers      = [14]
  tunnel2_phase2_dh_group_numbers      = [14]
  tunnel1_phase2_lifetime_seconds      = 3600
  tunnel2_phase2_lifetime_seconds      = 3600

  tags = {Name= "onprem-to-tgw"}
}

###########################################################
# 5) TGW ↔ VPC Attachment (connects TGW to test VPC)
###########################################################
# Attach the VPC’s PRIVATE subnets so traffic stays internal.
# We explicitly disable default association/propagation so we
# can attach this VPC to the onprem RT only.
resource "aws_ec2_transit_gateway_vpc_attachment" "test" {
  # subnet_ids = [
  #   aws_subnet.kuflink_private_subnet_a.id,
  #   aws_subnet.kuflink_private_subnet_b.id,
  #   aws_subnet.kuflink_private_subnet_c.id,
  # ]
  subnet_ids = module.vpc.private_subnet_cidrs

  transit_gateway_id = aws_ec2_transit_gateway.core_tgw.id
  vpc_id             = module.vpc.vpc_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {Name= "test-vpc-to-tgw"}
}

############################################################
# 6) Associate both attachments to the on‑prem TGW RT
############################################################
# This tells the TGW which attachments participate in this
# route table’s forwarding decisions.
resource "aws_ec2_transit_gateway_route_table_association" "test_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.test.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.onprem.id
  replace_existing_association   = true
}

resource "aws_ec2_transit_gateway_route_table_association" "vpn_assoc" {
  transit_gateway_attachment_id  = aws_vpn_connection.onprem_to_tgw.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.onprem.id
  
  replace_existing_association   = true
}

################################################################
# 7) (Optional) Propagation — if you want attachments to publish
#    their routes automatically into the TGW route table.
################################################################
# With static routing you can skip this and manage routes below.
resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_propagation" {
  transit_gateway_attachment_id  = aws_vpn_connection.onprem_to_tgw.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.onprem.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "test_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.test.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.onprem.id
}

###############################################################
# 8) TGW static route → send 10.0.0.0/16 to the VPC attachment
###############################################################
# Ensures packets arriving over the VPN destined for AWS VPC
# CIDR are forwarded to the VPC attachment.
resource "aws_ec2_transit_gateway_route" "to_test_vpc" {
  destination_cidr_block         = module.vpc.vpc_cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.onprem.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.test.id
}

###################################################################
# 9) VPC route tables (private subnets) → on‑prem via the TGW
###################################################################
# Every private route table needs a route to on‑prem CIDR(s) via TGW,
# so instances in private subnets can reach on‑prem systems.
resource "aws_route" "vpc_to_onprem" {
  for_each = {
    for rt in var.private_route_table_ids : rt => rt
  }
  route_table_id         = each.value
  destination_cidr_block = var.onprem_cidrs[0]   # change to iterate if multiple
  transit_gateway_id     = aws_ec2_transit_gateway.core_tgw.id
}
