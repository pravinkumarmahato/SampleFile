output "lt" {
  description = "The 'aws_launch_template.lt' resource."
  value       = aws_launch_template.lt
}

output "asg" {
  description = "The 'aws_autoscaling_group.ec2-asg' resource."
  value       = aws_autoscaling_group.asg
}

output "sg" {
  description = "The 'aws_security_group.sg' resource."
  value       = aws_security_group.sg[0]
}
