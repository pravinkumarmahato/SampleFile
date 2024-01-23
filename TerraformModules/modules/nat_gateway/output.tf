output "id" {
  value       = aws_nat_gateway.nat.id
  description = "The ID of the NAT Gateway"
}

output "network_interface_id" {
  value       = aws_nat_gateway.nat.network_interface_id
  description = "The ID of the network interface associated with the NAT gateway"
}

output "public_ip" {
  value       = aws_nat_gateway.nat.public_ip
  description = "The Elastic IP address associated with the NAT gateway"
}
