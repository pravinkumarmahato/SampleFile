resource "aws_security_group" "sg" {
  name        = var.sg_name
  description = var.sg_desc
  vpc_id      = var.vpc_id
  tags        = var.tags
  lifecycle {
    ignore_changes = [
      revoke_rules_on_delete, tags
    ]
  }
}

