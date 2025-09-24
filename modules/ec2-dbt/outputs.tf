# output "dbt_elastic_ip" {
#   value = aws_eip.dbt_eip.public_ip
# }

output "dbt_instance_id" {
  value = aws_instance.dbt_host.id
}

output "dbt_private_ip" {
  value = aws_instance.dbt_host.private_ip
}
