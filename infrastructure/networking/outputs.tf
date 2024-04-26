output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the created public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the created private subnet"
  value       = aws_subnet.private.id
}

output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.allow_all.id
}
