output "wordpress_test_instance_private_ip" {
  value = aws_instance.kuflink_ec2.private_ip
}

output "wordpress_test_instance_id" {
  value = aws_instance.kuflink_ec2.id
}

output "wordpress_test_instance_arn" {
  value = aws_instance.kuflink_ec2.arn
}


