variable "role_name" {
  type        = string
  description = "Name of the iam role"
}
variable "custom_policies" {
  type        = list(string)
  description = "List of custom policies for IAM role"
}
variable "managed_policy_arns" {
  type        = list(string)
  description = "List of ARN's of aws managed policies"
}

variable "assume_role_policy" {
  type        = string
  description = "Assume role policy for role"
}

variable "tags" {
  type        = map(any)
  description = "Map of tags"
}

variable "description" {
  type        = string
  description = "IAM role description"
  default     = ""
}

variable "path" {
  type        = string
  description = "Path to the role"
  default     = "/"
}
