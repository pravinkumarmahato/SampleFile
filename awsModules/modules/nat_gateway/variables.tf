variable "tags" {
  type        = map(any)
  description = "map of tags"
  default = {}
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet"
}
