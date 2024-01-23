# terraform-aws-s3-bucket

## Example Usage

> Pleae review the [Specifying AWS SSO roles in policy documents](#sso_roles) section for information on how to look up AWS SSO roles

### Standard S3 bucket with secure bucket policy

```hcl
data "aws_caller_identity" "current" {}

data "aws_iam_roles" "globaladmin_sso" {
  name_regex  = "AWSReservedSSO_GlobalAdmin_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

module "s3_bucket" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-s3-bucket.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/s3-bucket/aws"
  version = "<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  bucket_name      = "example-bucket"
  bucket_acl       = "private"
  object_ownership = "BucketOwnerEnforced"

  kms_key_arn = module.cmk.key.arn

  block_public_access = true
  enable_versioning   = false

  delete_incomplete_uploads_days = 30

  current_version_transitions = {
    WholeBucket_Current_Use_Intelligent_Tiering = {
      enabled         = true
      prefix          = ""
      storage_class   = "INTELLIGENT_TIERING"
      transition_days = 1
    }
  }

  current_version_expirations = {}
  previous_version_transitions = {}
  previous_version_expirations = {}

  crr_configuration = {}
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid = "AllowSSLOnly" # Only allow HTTPS requests
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      module.s3_bucket.bucket.arn,
      "${module.s3_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  statement {
    sid = "RequireRoleMembership" ## Denies access to this S3 bucket unless the request is authenticated using a specified IAM entity
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      module.s3_bucket.bucket.arn,
      "${module.s3_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalArn"
      values = concat(
        [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DivvyCloud", # Include this role to allow GRC to report on compliance
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/<role_name>",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/<user_name>",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-policy/<instance_policy>"
        ],
        tolist(data.aws_iam_roles.globaladmin_sso.arns)
      )
    }
  }
  statement {
    sid = "DenyUnencryptedObjectUploads" ## Denies put operations that do not specify encryption
    actions = [
      "s3:PutObject"
    ]
    effect = "Deny"
    resources = [
      "${module.s3_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }
  statement {
    sid = "DenyIncorrectEncryptionHeader" ## Denies requests that specify the wrong encryption type
    actions = [
      "s3:PutObject"
    ]
    effect = "Deny"
    resources = [
      "${module.s3_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
  statement {
    sid = "RequireCMKKey" ## Forces the specified KMS key to be used when uploading objects to this S3 bucket
    actions = [
      "s3:PutObject"
    ]
    effect = "Deny"
    resources = [
      "${module.s3_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values = [
        module.cmk.key.arn
      ]
    }
  }
}
```

### Bucket deployed with lifecycle rules for transitions and expirations

```hcl
module "s3_bucket" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-s3-bucket.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/s3-bucket/aws"
  version = "<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  bucket_name      = "example-bucket"
  bucket_acl       = "private"
  object_ownership = "BucketOwnerEnforced"

  kms_key_arn = module.cmk.key.arn

  block_public_access = true
  enable_versioning   = false

  delete_incomplete_uploads_days = 30

  current_version_transitions = {
    WholeBucket_Current_Use_Intelligent_Tiering = {
      enabled         = true
      prefix          = ""
      storage_class   = "INTELLIGENT_TIERING"
      transition_days = 1
    }
  }

  current_version_expirations = {
    TempFolder_Current_Delete_After_30_Days = {
      enabled         = true
      prefix          = "temp/"
      expiration_days = 30
    }
  }

  previous_version_transitions = {
    WholeBucket_Previous_Use_OneZone_IA_After_90_Days = {
      enabled         = true
      prefix          = ""
      storage_class   = "ONEZONE_IA"
      transition_days = 90
    }
  }

  previous_version_expirations = {
    WholeBucket_Previous_Delete_Versions_After_180_Days = {
      enabled         = true
      prefix          = ""
      expiration_days = 180
    }
  }

  crr_configuration = {}
}
```

### Buckets with cross-region replication and secure bucket policies

> Primary S3 bucket deployed with replication configuration and role. Secondary bucket deployed using primary bucket's role and configuration.

```hcl
data "aws_caller_identity" "current" {
  provider = aws.primary
}

data "aws_iam_roles" "globaladmin_sso" {
  name_regex  = "AWSReservedSSO_GlobalAdmin_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

module "primary_s3_bucket" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-s3-bucket.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/s3-bucket/aws"
  version = "<current version>"

  providers = {
    aws = aws.primary
  }

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  bucket_name      = "example-primary"
  bucket_acl       = "private"
  object_ownership = "BucketOwnerEnforced"

  kms_key_arn = module.primary_cmk.key.arn

  delete_incomplete_uploads_days = 30

  current_version_transitions = {}
  current_version_expirations = {}
  previous_version_transitions = {}
  previous_version_expirations = {}

  crr_configuration = {
    default = {
      priority                  = 0
      status                    = "Enabled"
      bucket_arn                = module.secondary_bucket.bucket.arn
      prefix                    = null
      storage_class             = "INTELLIGENT_TIERING"
      role_arn                  = module.s3_crr_role.role.arn
      cmk_arn                   = module.secondary_cmk.key.arn
      delete_marker_replication = true
      account_id                = null
    }
  }
}

resource "aws_s3_bucket_policy" "primary_attach" {
  provider = aws.primary
  bucket   = module.primary_bucket.bucket.id
  policy   = data.aws_iam_policy_document.primary_bucket_policy.json
}

data "aws_iam_policy_document" "primary_bucket_policy" {
  statement {
    sid = "AllowSSLOnly" # Only allow HTTPS requests
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      module.primary_bucket.bucket.arn,
      "${module.primary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  statement {
    sid = "RequireRoleMembership" ## Denies access to this S3 bucket unless the request is authenticated using a specified IAM entity
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      module.primary_bucket.bucket.arn,
      "${module.primary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalArn"
      values = concat(
        [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DivvyCloud", # Include this role to allow GRC to report on compliance
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole",
          module.s3_crr_role.role.arn
        ],
        tolist(data.aws_iam_roles.globaladmin_sso.arns)
      )
    }
  }
  statement {
    sid = "DenyUnencryptedObjectUploads" ## Denies put operations that do not specify encryption
    actions = [
      "s3:PutObject"
    ]
    effect = "Deny"
    resources = [
      "${module.primary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }
  statement {
    sid = "DenyIncorrectEncryptionHeader" ## Denies requests that specify the wrong encryption type
    actions = [
      "s3:PutObject"
    ]
    effect = "Deny"
    resources = [
      "${module.primary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
  statement {
    sid = "RequireCMKKey" ## Forces the specified KMS key to be used when uploading objects to this S3 bucket
    actions = [
      "s3:PutObject"
    ]
    effect = "Deny"
    resources = [
      "${module.primary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values = [
        module.primary_cmk.key.arn
      ]
    }
  }
}

module "secondary_s3_bucket" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-s3-bucket.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/s3-bucket/aws"
  version = "<current version>"

  providers = {
    aws = aws.secondary
  }

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  bucket_name      = "example-secondary"
  bucket_acl       = "private"
  object_ownership = "BucketOwnerEnforced"

  kms_key_arn = module.secondary_cmk.key.arn

  block_public_access     = true
  enable_versioning       = true

  delete_incomplete_uploads_days = 30

  current_version_transitions = {}
  current_version_expirations = {}
  previous_version_transitions = {}
  previous_version_expirations = {}

  crr_configuration = {}
}

resource "aws_s3_bucket_policy" "secondary_attach" {
  provider = aws.secondary
  bucket   = module.secondary_bucket.bucket.id
  policy   = data.aws_iam_policy_document.secondary_bucket_policy.json
}

data "aws_iam_policy_document" "secondary_bucket_policy" {
  statement {
    sid = "AllowSSLOnly" # Only allow HTTPS requests
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      module.secondary_bucket.bucket.arn,
      "${module.secondary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  statement {
    sid = "RequireRoleMembership" ## Denies access to this S3 bucket unless the request is authenticated using a specified IAM entity
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      module.secondary_bucket.bucket.arn,
      "${module.secondary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalArn"
      values = concat(
        [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DivvyCloud", # Include this role to allow GRC to report on compliance
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole",
          module.s3_crr_role.role.arn
        ],
        tolist(data.aws_iam_roles.globaladmin_sso.arns)
      )
    }
  }
  statement {
    sid = "DenyUnencryptedObjectUploads" ## Denies put operations that do not specify encryption
    actions = [
      "s3:PutObject"
    ]
    effect = "Deny"
    resources = [
      "${module.secondary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }
  statement {
    sid = "DenyIncorrectEncryptionHeader" ## Denies requests that specify the wrong encryption type
    actions = [
      "s3:PutObject"
    ]
    effect = "Deny"
    resources = [
      "${module.secondary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
  statement {
    sid = "RequireCMKKey" ## Forces the specified KMS key to be used when uploading objects to this S3 bucket
    actions = [
      "s3:PutObject"
    ]
    effect = "Deny"
    resources = [
      "${module.secondary_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values = [
        module.secondary_cmk.key.arn
      ]
    }
  }
}
```

### IAM role and policy for CRR

```hcl
module "s3_crr_role" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-iam-role.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/iam-role/aws"
  version = "<current version>"

  tags = var.tags

  iam_role_name        = "example-s3-crr"
  iam_role_path        = "Example"
  iam_role_description = "Allows primary S3 bucket to replicate to bucket in secondary region."
  permissions_boundary = null
  instance_profile     = false

  iam_managed_policies = [
    module.s3_crr_policy.policy.arn
  ]

  assume_role_policy = [
    {
      effect      = "Allow"
      actions     = [
        "sts:AssumeRole"
      ]
      not_actions = []
      principals = {
        EC2 = {
          type        = "Service"
          identifiers = [
            "s3.amazonaws.com"
          ]
        }
      }
      not_principals = {}
      condition      = {}
    }
  ]
}

module "s3_crr_policy" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-iam-policy.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/iam-policy/aws"
  version = "<current version>"

  tags = var.tags

  iam_policy_name        = "example-s3-crr-policy"
  iam_policy_path        = "Example"
  iam_policy_description = "Allows replication of source bucket to secondary region replica bucket."

  managed_policy = [
    {
      sid    = "AllowGetSourceBucketConfig"
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:GetReplicationConfiguration",
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging",
        "s3:GetObjectRetention",
        "s3:GetObjectLegalHold"
      ]
      not_actions = []
      resources = [
        module.primary_bucket.bucket.arn,
        "${module.primary_bucket.bucket.arn}/*",
      ]
      not_resources  = []
      principals     = {}
      not_principals = {}
      condition      = {}
    },
    {
      sid    = "EnableSourceKeyUsagePermissions"
      effect = "Allow"
      actions = [
        "kms:Decrypt"
      ]
      not_actions = []
      resources = [
        module.primary_key.key.arn
      ]
      not_resources  = []
      principals     = {}
      not_principals = {}
      condition = {
        s3service = {
          test     = "StringLike"
          variable = "kms:ViaService"
          values   = [
            "s3.${data.aws_region.primary.name}.amazonaws.com"
          ]
        },
        kmscheck = {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:s3:arn"
          values   = [
            "${module.primary_bucket.bucket.arn}/*"
          ]
        }
      }
    },
    {
      sid    = "AllowReplicateToDestinationBucket"
      effect = "Allow"
      actions = [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags",
        "s3:GetObjectVersionTagging"
      ]
      not_actions = []
      resources   = [
        "${module.secondary_bucket.bucket.arn}/*"
      ]
      not_resources  = []
      principals     = {}
      not_principals = {}
      condition = {
        RequireKms = {
          test     = "StringLikeIfExists"
          variable = "s3:x-amz-server-side-encryption"
          values   = [
            "aws:kms"
          ]
        },
        RequireKmsKey = {
          test     = "StringLikeIfExists"
          variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
          values   = [
            module.secondary_key.key.
          ]
        }
      }
    },
    {
      sid    = "EnableDestinationKeyUsagePermissions"
      effect = "Allow"
      actions = [
        "kms:Encrypt"
      ]
      not_actions = []
      resources = [
        module.secondary_key.key.arn
      ]
      not_resources  = []
      principals     = {}
      not_principals = {}
      condition = {
        s3service = {
          test     = "StringLike"
          variable = "kms:ViaService"
          values   = [
            "s3.${data.aws_region.secondary.name}.amazonaws.com"
          ]
        }
        kmscheck = {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:s3:arn"
          values   = [
            "${module.secondary_bucket.bucket.arn}/*"
          ]
        }
      }
    }
  ]
}
```

where `<current version>` is the most recent release.

<!----><a name="sso_roles"></a>
## Specifying AWS SSO roles in policy documents

AWS SSO role names are not consistent across accounts. This is unfortunately not something we can control. Because of this, we are unable to use the `aws_iam_role` data source as it does not accept wildcards. We can use the `aws_iam_roles` data source to look these up based on a regex pattern.

> Important note: The `aws_iam_roles` data source outputs a set.  We will need to convert this to a list when passing the arns as show in the example below.

```hcl
data "aws_iam_roles" "globaladmin_sso" {
  name_regex  = "AWSReservedSSO_GlobalAdmin_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "sreadmin_sso" {
  name_regex  = "AWSReservedSSO_SREAdmin.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_policy_document" "sso_example" {
  statement {
    sid = "RequireRoleMembership"

    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalArn"
      values = concat(
        [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ExampleRoleName"
        ],
        tolist(data.aws_iam_roles.globaladmin_sso.arns),
        tolist(data.aws_iam_roles.sreadmin_sso.arns)
      )
    }
  }
}
```

## Related Links

- [CBRE Tagging Policy](https://intranet.cbre.com/Sites/Americas-UnitedStates-DigitalTechnology/en-US/Documents/Digital%20and%20Tech%20Policies/CBRE%20Cloud%20CoE%20Cloud%20Tagging%20Policy.pdf)
- [Canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl)
- [Object Ownership](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html)

## Object specific arguments

### current_version_transitions

| Name | Description |
|------|-------------|
| `current_version_transitions.key` | Must provide a unique name for each key in the map. For example, `WholeBucket_Current_Use_Intelligent_Tiering`. The key will also be used as the `id` for each rule.
| `current_version_transitions.enabled` | Whether to enable this rule.
| `current_version_transitions.prefix` | Object key prefix identifying one or more objects to which the rule applies. Set this to `""` to scope the entire bucket.
| `current_version_transitions.storage_class` | Specifies the Amazon S3 storage class to which you want the object to transition. Can be one of `GLACIER`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `DEEP_ARCHIVE`, `GLACIER_IR`.
| `current_version_transitions.transition_days` | Specifies the number of days after object creation when the specific rule action takes effect.

### current_version_expirations

> **WARNING**: Configuring this varible will delete current versions of objects in this bucket.  Please ensure you understand the risks before using this variable.

| Name | Description |
|------|-------------|
| `current_version_expirations.key` | Must provide a unique name for each key in the map. For example, `WholeBucket_Current_Delete_After_30_Days`. The key will also be used as the `id` for each rule.
| `current_version_expirations.enabled` | Whether to enable this rule.
| `current_version_expirations.prefix` | Object key prefix identifying one or more objects to which the rule applies. Set this to `""` to scope the entire bucket.
| `current_version_expirations.expiration_days` | Specifies the number of days after which current object versions will be deleted.

### previous_version_transitions

| Name | Description |
|------|-------------|
| `previous_version_transitions.key` | Must provide a unique name for each key in the map. For example, `WholeBucket_Previous_Use_OneZone_IA_After_90_Days`. The key will also be used as the `id` for each rule.
| `previous_version_transitions.enabled` | Whether to enable this rule.
| `previous_version_transitions.prefix` | Object key prefix identifying one or more objects to which the rule applies. Set this to `""` to scope the entire bucket.
| `previous_version_transitions.storage_class` | Specifies the Amazon S3 storage class to which you want the object to transition. Can be one of `GLACIER`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `DEEP_ARCHIVE`, `GLACIER_IR`.
| `previous_version_transitions.transition_days` | Specifies the number of days after object creation when the specific rule action takes effect.

### previous_version_expirations

| Name | Description |
|------|-------------|
| `previous_version_expirations.key` | Must provide a unique name for each key in the map. For example, `WholeBucket_Previous_Delete_Versions_After_180_Days`. The key will also be used as the `id` for each rule.
| `previous_version_expirations.enabled` | Whether to enable this rule.
| `previous_version_expirations.prefix` | Object key prefix identifying one or more objects to which the rule applies. Set this to `""` to scope the entire bucket.
| `previous_version_expirations.expiration_days` | Specifies the number of days after which previous object versions will be deleted.

### crr_configuration

| Name | Description |
|------|-------------|
| `crr_configuration.key` | Must provide a unique name for each key in the map. For example, `default`. The key will also be used as the `id` for each rule.
| `crr_configuration.priority` | Specifies the number of days after object creation when the specific rule action takes effect.
| `crr_configuration.status` | Whether to enable this rule.  Can be either `Enabled` or `Disabled`.
| `crr_configuration.bucket_arn` | The ARN of the S3 bucket where you want Amazon S3 to replicate to.
| `crr_configuration.prefix` | Object key prefix identifying one or more objects to which the rule applies. Set this to `""` to scope the entire bucket.
| `crr_configuration.storage_class` | The storage class used to store the object. If set to `null`, Amazon S3 uses the storage class of the source object to create the object replica.
| `crr_configuration.role_arn` | The ARN of the IAM role for Amazon S3 to assume when replicating the objects. Must be provided for both source and destination buckets.
| `crr_configuration.cmk_arn` | The destination bucket's KMS encryption key ARN for SSE-KMS replication.
| `crr_configuration.delete_marker_replication` | Whether delete markers are replicated.
| `crr_configuration.account_id` | If replicating to a bucket in the same AWS account, set this to `null`.  If replicating to a bucket in another AWS account, set this to the destination account ID to change the owner of the replicated objects to the destination account.

## Development

Feel free to create a branch and submit a pull request to make changes to the module.

## License

Copyright: 2022, CBRE Group, Inc., All Rights Reserved.
