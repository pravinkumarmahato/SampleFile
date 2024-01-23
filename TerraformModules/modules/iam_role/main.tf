
resource "aws_iam_role" "iam_role" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
  description        = var.description
  path               = var.path
  tags               = var.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_iam_role_policy_attachment" "custom_policy_attachment" {
  count      = length(var.custom_policies)
  policy_arn = var.custom_policies[count.index]
  role       = aws_iam_role.iam_role.name
}

resource "aws_iam_role_policy_attachment" "managed_policy_attachment" {
  count      = length(var.managed_policy_arns)
  policy_arn = var.managed_policy_arns[count.index]
  role       = aws_iam_role.iam_role.name
}
