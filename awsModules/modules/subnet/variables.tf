variable "cidr_block" {
  type        = string
  description = "The IPv4 CIDR block for the subnet"
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "az" {
  type        = string
  description = "AZ ID of the subnet. This argument is not supported in all regions or partitions"
}

variable "tags" {
  type        = map(any)
  description = "A map of tags to assign to the resource"
  default = {}
}

  