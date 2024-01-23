variable "policy_name" {
  type        = string
  description = "Name of the policy"
}

variable "custom_policy" {
  type        = string
  description = "Policy document"
}

variable "description" {
  type        = string
  description = "description for iam role policy"
}

variable "path" {
  type        = string
  description = "Path"
  default     = "/"
}

variable "tags" {
  type = map
  description = "Map of tags"
  default = {}
}