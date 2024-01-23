resource "aws_iam_policy" "custom_policy" {
  name        = var.policy_name
  policy      = var.custom_policy
  description = var.description
  path        = var.path
  tags        = var.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

