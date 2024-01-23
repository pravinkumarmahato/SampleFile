output "id" {
  value       = aws_subnet.subnet.id
  description = "The ID of the subnet"
}

output "arn" {
  value       = aws_subnet.subnet.arn
  description = "The ARN of the subnet"
}

output "subnet_owner_id" {
  value       = aws_subnet.subnet.owner_id
  description = "The ID of the AWS account that owns the subnet"
}
