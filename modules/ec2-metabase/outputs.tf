output "metabase_test_instance_private_ip" {
  value = aws_instance.kuflink_ec2.private_ip
}

output "metabase_test_instance_id" {
  value = aws_instance.kuflink_ec2.id
}

output "metabase_test_instance_arn" {
  value = aws_instance.kuflink_ec2.arn
}


