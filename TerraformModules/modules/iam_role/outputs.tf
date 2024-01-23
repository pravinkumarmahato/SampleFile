output "arn" {
  value       = aws_iam_role.iam_role.arn
  description = "Amazon Resource Name (ARN) specifying the role"
}

output "id" {
  value       = aws_iam_role.iam_role.id
  description = "Name of the role"
}

output "name" {
  value       = aws_iam_role.iam_role.name
  description = "Name of the role"
}