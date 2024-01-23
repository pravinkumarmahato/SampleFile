output "cluster" {
  description = "The 'aws_rds_cluster.cluster' resource."
  value       = aws_rds_cluster.cluster
  sensitive   = true
}

output "instance" {
  description = "The 'aws_rds_cluster_instance.instance' resource."
  value       = aws_rds_cluster_instance.instance
}
