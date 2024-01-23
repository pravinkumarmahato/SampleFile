output "route_table_id" {
  value       = aws_route_table.route_table.id
  description = "The ID of the routing table"
}

output "route_table_arn" {
  value       = aws_route_table.route_table.arn
  description = "The ARN of the route table."
}

output "route_table_owner_id" {
  value       = aws_route_table.route_table.owner_id
  description = "The ID of the AWS account that owns the route table"
}