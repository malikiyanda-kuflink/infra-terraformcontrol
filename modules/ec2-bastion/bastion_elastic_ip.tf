resource "aws_eip" "bastion_eip" {
  domain = "vpc"
  tags   = { Name = var.bastion_elastic_ip_name }
}

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion_host.id
  allocation_id = aws_eip.bastion_eip.id

}
