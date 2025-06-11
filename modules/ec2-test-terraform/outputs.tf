output "test_instance_private_ip" {
  value = aws_instance.test_instance.private_ip
}

output "test_instance_id" {
  value = aws_instance.test_instance.id
}
