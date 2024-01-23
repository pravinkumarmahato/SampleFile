resource "aws_security_group_rule" "rule" {
  count                    = length(var.source_security_group_ids)
  type                     = var.type
  security_group_id        = var.sg_id
  from_port                = var.from_port
  to_port                  = var.to_port
  protocol                 = var.protocol
  source_security_group_id = var.source_security_group_ids[count.index]
  prefix_list_ids          = var.prefix_list_ids
  description       = length(var.description) > 0 ? var.description[count.index] : ""
  lifecycle {
    ignore_changes = [
      description
    ]
  }
}
