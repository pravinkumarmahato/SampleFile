

variable "tags" {
  type        = map(any)
  description = "A map of tags to assign to the resource"
  default = {}
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "gateway_id" {
  type        = string
  description = "Identifier of a VPC NAT gateway"
}
