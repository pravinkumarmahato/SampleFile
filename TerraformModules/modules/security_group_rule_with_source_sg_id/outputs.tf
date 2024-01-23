output "security_group_rule_id" {
  value       = aws_security_group_rule.rule.*.id
  description = "Security group rule id"
}