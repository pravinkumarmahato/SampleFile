output "instance_master" {
  description = "The 'aws_db_instance.master' resouce."
  value       = aws_db_instance.master
}

output "instance_replicas" {
  description = "The 'aws_db_instance.replica[*]' resource(s)."
  value       = aws_db_instance.replica[*]
}
