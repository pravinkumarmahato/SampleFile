resource "aws_security_group_rule" "rule" {
  count             = length(var.cidr_blocks)
  type              = var.type
  security_group_id = var.sg_id
  from_port         = var.from_port
  to_port           = var.to_port
  protocol          = var.protocol
  cidr_blocks       = [var.cidr_blocks[count.index]]
  prefix_list_ids   = var.prefix_list_ids
  description       = length(var.description) > 0 ? var.description[count.index] : ""
  lifecycle {
    ignore_changes = [
      description
    ]
  }
}
