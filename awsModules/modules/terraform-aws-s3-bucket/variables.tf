variable "tags" {
  description = "Please reference the current tagging policy for required tags and allowed values.  See README for link to policy."
  type        = map(string)
}

variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "bucket_acl" {
  description = "The 'Canned ACL' to apply. See README for link to Canned ACL documentation."
  type        = string
  default     = "private"
}

variable "kms_key_arn" {
  description = "Amazon CMK ARN for KMS key used for Amazon S3 server side encryption. This value _must_ be an AWS CMK ARN and not an ID or alias.  If set to 'null', an AWS managed KMS key will be used to encrypt this bucket."
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "Specifies whether or not to allow objects to be public."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Specifies whether or not to enable versioning on the bucket."
  type        = bool
  default     = false
}

variable "current_version_transitions" {
  description = "Lifecycle rule to manage storage tier transitions for objects in this bucket. See object specific arguments in the README."
  type = map(object({
    enabled         = bool
    prefix          = string
    storage_class   = string
    transition_days = number
  }))
  default  = {}
  nullable = false
}

variable "current_version_expirations" {
  description = "Lifecycle rule to automatically delete objects in this bucket after a set number of days. See object specific arguments in the README.  WARNING: Configuring this varible will delete current versions of objects in this bucket.  Please ensure you understand the risks before using this variable."
  type = map(object({
    enabled         = bool
    prefix          = string
    expiration_days = number
  }))
  default  = {}
  nullable = false
}

variable "previous_version_transitions" {
  description = "Lifecycle rule to manage storage tier transitions for previous object versions.  Only applicable if 'enable_versioning' is set to 'true'. See object specific arguments in the README."
  type = map(object({
    enabled         = bool
    prefix          = string
    storage_class   = string
    transition_days = number
  }))
  default  = {}
  nullable = false
}

variable "previous_version_expirations" {
  description = "Lifecycle rule to automatically delete previous object versions after a set number of days.  Only applicable if 'enable_versioning' is set to 'true'. See object specific arguments in the README."
  type = map(object({
    enabled         = bool
    prefix          = string
    expiration_days = number
  }))
  default  = {}
  nullable = false
}

variable "crr_configuration" {
  description = "Cross-region replication configuration for the source bucket. See object specific arguments in the README."
  type = map(object({
    priority                  = string
    status                    = string
    bucket_arn                = string
    prefix                    = string
    storage_class             = string
    role_arn                  = string
    cmk_arn                   = string
    delete_marker_replication = bool
    account_id                = string
  }))
  default  = {}
  nullable = false
}

variable "delete_incomplete_uploads_days" {
  description = "The number of days to keep incomplete multi-part uploads."
  type        = number
  default     = 30
}

variable "object_ownership" {
  description = "Manages object ownership settings.  Valid values are ['BucketOwnerPreferred','ObjectWriter','BucketOwnerEnforced']. See the 'Object Ownership' link in the readme for more info."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition = (
      var.object_ownership != "BucketOwnerPreferred"
      || var.object_ownership != "ObjectWriter"
      || var.object_ownership != "BucketOwnerEnforced"
    )
    error_message = "The 'object_ownership' must be one of ['BucketOwnerPreferred','ObjectWriter','BucketOwnerEnforced']."
  }
}

locals {
  tags = merge(
    var.tags,
    {
      cloud_module = "aws-s3-bucket_2-5-0"
    }
  )
}
