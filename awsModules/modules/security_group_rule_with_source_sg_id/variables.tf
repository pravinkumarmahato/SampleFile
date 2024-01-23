variable "sg_id" {
  type        = string
  description = "ID of the security group"
}

variable "from_port" {
  type        = number
  description = "Start port (or ICMP type number if protocol is 'icmp' or 'icmpv6')"
}

variable "to_port" {
  type        = number
  description = "End port (or ICMP code if protocol is 'icmp')"
}

variable "protocol" {
  type        = string
  description = "Protocol"
}

variable "source_security_group_ids" {
  type        = list(string)
  description = "Security group id to allow access to/from"
}

variable "type" {
  type        = string
  description = "Type of rule being created"
}

variable "prefix_list_ids" {
  type        = list(string)
  description = "List of Prefix List IDs"
}

variable "description" {
  type = list(string)
}
