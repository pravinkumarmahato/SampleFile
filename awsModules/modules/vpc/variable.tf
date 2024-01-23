

variable "vpc_cidr" {
  type = string
  default = ""
}

variable "tags" {
  type = map(any)
  default = {}
}

variable "enable_dns_support" {
  type = bool
  description = "Flag to enable DNS support"
  default = true
}

variable "enable_dns_hostnames" {
  type = bool
  description = "Flag to enable DNS hostnames"
  default = true
}
