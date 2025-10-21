# output "dbt_elastic_ip" {
#   value = aws_eip.dbt_eip.public_ip
# }

output "dbt_instance_id" {
  value = aws_instance.dbt_host.id
}

output "dbt_private_ip" {
  value = aws_instance.dbt_host.private_ip
}


output "dbt_alb_dns_name" {
  value       = aws_lb.dbt_docs.dns_name
  description = "DNS name of the ALB for accessing dbt docs"
}

output "dbt_docs_url" {
  value       = "http://${aws_lb.dbt_docs.dns_name}"
  description = "URL to access dbt docs"
}

output "dbt_docs_subdomain" {
  value       = var.dbt_docs_subdomain
  description = "Subdomain for accessing dbt docs"
}