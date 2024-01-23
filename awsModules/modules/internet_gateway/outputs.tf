output "igw_id" {
  value       = aws_internet_gateway.igw.id
  description = "The ID of the Internet Gateway"
}

output "igw_arn" {
  value       = aws_internet_gateway.igw.arn
  description = "The ARN of the Internet Gateway"
}

output "igw_owner_id" {
  value       = aws_internet_gateway.igw.owner_id
  description = "The ID of the AWS account that owns the internet gateway"
}

