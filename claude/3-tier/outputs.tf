# outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "web_instance_ids" {
  description = "IDs of web tier instances"
  value       = aws_instance.web[*].id
}

output "app_instance_ids" {
  description = "IDs of app tier instances"
  value       = aws_instance.app[*].id
}

output "rds_endpoint" {
  description = "Endpoint of the RDS MySQL instance"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "nat_gateway_ip" {
  description = "Elastic IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}