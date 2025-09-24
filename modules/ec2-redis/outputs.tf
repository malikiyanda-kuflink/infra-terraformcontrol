output "redis_instance_id" {
  value = aws_instance.redis_host.id
}

output "redis_private_ip" {
  value = aws_instance.redis_host.private_ip
}



