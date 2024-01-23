variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "sg_name" {
  type        = string
  description = "Name for security group"
}

variable "sg_desc" {
  type        = string
  description = "Description for security group"
}

variable "tags" {
  type        = map(any)
  description = "map of tags"
  default = {}
}