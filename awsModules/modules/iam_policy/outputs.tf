output "id" {
  value       = aws_iam_policy.custom_policy.id
  description = "The ARN assigned by AWS to this policy"
}

output "arn" {
  value       = aws_iam_policy.custom_policy.arn
  description = "The ARN assigned by AWS to this policy"
}

output "name" {
  value       = aws_iam_policy.custom_policy.name
  description = "The name of the policy"
}

output "path" {
  value       = aws_iam_policy.custom_policy.path
  description = "The path of the policy in IAM"
}

output "policy" {
  value       = aws_iam_policy.custom_policy.policy
  description = "The policy document"
}

output "policy_id" {
  value       = aws_iam_policy.custom_policy.policy_id
  description = "The policy's ID"
}