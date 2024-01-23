output "alb" {
  description = "The 'aws_lb.alb' resource."
  value       = aws_lb.alb
}

output "listeners" {
  description = "The 'aws_lb_listener.front_end' resource(s)."
  value       = values(aws_lb_listener.front_end)[*]
}

output "tgs" {
  description = "The 'aws_lb_target_group.tg' resource(s)."
  value       = values(aws_lb_target_group.tg)[*]
}

output "sg" {
  description = "The 'aws_security_group.group' resource."
  value       = aws_security_group.group
}
