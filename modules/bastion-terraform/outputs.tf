output "bastion_elastic_ip" {
  value = aws_eip.bastion_eip.public_ip
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "bastion_instance_id" {
  value = aws_instance.bastion_host.id
}

output "bastion_private_id" {
  value = aws_instance.bastion_host.private_ip
}
