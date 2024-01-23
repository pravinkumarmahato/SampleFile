data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "bucket" {
  bucket = lower(var.bucket_name)

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "block" {
  depends_on = [aws_s3_bucket.bucket]

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_acl" "acl" {
  count = var.object_ownership != "BucketOwnerEnforced" ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  acl    = var.bucket_acl

  depends_on = [
    aws_s3_bucket_ownership_controls.owner_control
  ]
}

resource "aws_s3_bucket_ownership_controls" "owner_control" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_config" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn != null ? var.kms_key_arn : null
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_replication_configuration" "rep_config" {
  for_each = var.crr_configuration

  depends_on = [aws_s3_bucket_versioning.versioning]

  bucket = aws_s3_bucket.bucket.id
  role   = each.value.role_arn

  rule {
    id       = each.key
    priority = each.value.priority
    status   = each.value.status

    filter {
      prefix = each.value.prefix
    }

    destination {
      bucket        = each.value.bucket_arn
      storage_class = each.value.storage_class
      account       = each.value.account_id

      encryption_configuration {
        replica_kms_key_id = each.value.cmk_arn
      }

      dynamic "access_control_translation" {
        for_each = each.value.account_id == null ? toset([]) : toset([1])
        content {
          owner = "Destination"
        }
      }
    }

    delete_marker_replication {
      status = each.value.delete_marker_replication ? "Enabled" : "Disabled"
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_config" {
  depends_on = [aws_s3_bucket_versioning.versioning]

  bucket = aws_s3_bucket.bucket.bucket

  rule {
    id = "Delete_Incomplete_Uploads"

    filter {
      prefix = ""
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = var.delete_incomplete_uploads_days
    }

    status = "Enabled"
  }

  dynamic "rule" {
    for_each = var.current_version_transitions

    content {
      id = rule.key

      filter {
        prefix = rule.value.prefix
      }

      transition {
        days          = rule.value.transition_days
        storage_class = rule.value.storage_class
      }

      status = rule.value.enabled ? "Enabled" : "Disabled"
    }
  }

  dynamic "rule" {
    for_each = var.current_version_expirations

    content {
      id = rule.key

      filter {
        prefix = rule.value.prefix
      }

      expiration {
        days = rule.value.expiration_days
      }

      status = rule.value.enabled ? "Enabled" : "Disabled"
    }
  }

  dynamic "rule" {
    for_each = var.previous_version_transitions

    content {
      id = rule.key

      filter {
        prefix = rule.value.prefix
      }

      noncurrent_version_transition {
        noncurrent_days = rule.value.transition_days
        storage_class   = rule.value.storage_class
      }

      status = rule.value.enabled ? "Enabled" : "Disabled"
    }
  }

  dynamic "rule" {
    for_each = var.previous_version_expirations

    content {
      id = rule.key

      filter {
        prefix = rule.value.prefix
      }

      noncurrent_version_expiration {
        noncurrent_days = rule.value.expiration_days
      }

      status = rule.value.enabled ? "Enabled" : "Disabled"
    }
  }
}
