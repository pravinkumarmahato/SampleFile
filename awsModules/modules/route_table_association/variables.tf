variable "subnet_ids" {
  type        = map(any)
  description = "map of subnet ids"
}

variable "route_table_id" {
  type        = string
  description = "Route table id"
}