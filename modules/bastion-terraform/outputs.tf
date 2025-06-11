output "bastion_elastic_ip" {
  value = aws_eip.bastion_eip.public_ip
}


output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
