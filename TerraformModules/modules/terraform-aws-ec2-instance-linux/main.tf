resource "aws_key_pair" "keypair" {
  for_each = var.key_name == null ? var.instances : {}

  tags = merge({ "Name" = "${each.key}-kp" }, var.tags)

  key_name   = "${each.key}-kp"
  public_key = var.keypair_public_key
}

data "aws_region" "current" {}

resource "aws_cloudwatch_metric_alarm" "noderecovery" {
  for_each = { for k, v in var.instances : k => v if v.enable_recovery_alarm }

  tags = merge({ "Name" = "${each.key}-alarm" }, var.tags)

  alarm_name          = "${each.key}-HostFailure-RecoveryAlarm"
  alarm_description   = "Recovering ${aws_instance.vm[each.key].id} when underlying hardware fails."
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"

  dimensions = {
    InstanceId = aws_instance.vm[each.key].id
  }
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["*${var.vpc_type}*"]
  }
}

data "aws_subnet" "selected" {
  for_each          = var.instances
  availability_zone = join("", [data.aws_region.current.name, each.value.availability_zone])
  vpc_id            = data.aws_vpc.selected.id
  tags = {
    Name = "*${var.subnet_type}*"
  }
}

resource "aws_security_group" "sg" {
  for_each = var.security_group_ids == null ? var.instances : {}

  name        = "${each.key}-sg"
  description = "${each.key} security group"
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
      self            = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
      description     = egress.value.description
      self            = egress.value.self
    }
  }

  tags = merge({ "Name" = "${each.key}-sg" }, var.tags)
}

resource "aws_instance" "vm" {
  for_each = var.instances

  ami                  = var.ami_id
  instance_type        = each.value.instance_type
  key_name             = var.key_name == null ? aws_key_pair.keypair[each.key].key_name : var.key_name
  iam_instance_profile = each.value.iam_instance_profile == null ? aws_iam_instance_profile.ssm_profile[each.key].name : each.value.iam_instance_profile

  vpc_security_group_ids = var.security_group_ids == null ? [aws_security_group.sg[each.key].id] : var.security_group_ids
  subnet_id              = data.aws_subnet.selected[each.key].id

  root_block_device {
    volume_size           = each.value.os_volume_size
    volume_type           = each.value.os_volume_type
    delete_on_termination = true
    tags                  = merge({ "Name" = "${each.key}:Root" }, var.tags)
  }

  tags = each.value.custodian_offhours == null ? merge({ "Name" = each.key }, var.tags) : merge({ "Name" = each.key, "CustodianOffHours" = each.value.custodian_offhours }, var.tags)

  user_data = each.value.user_data

  lifecycle {
    ignore_changes = [
      root_block_device[0].tags["LastAttachInstance"],
      root_block_device[0].tags["LastAttachTime"]
    ]
  }
}

resource "aws_iam_role" "ssm_role" {
  for_each = { for k, v in var.instances : k => v if v.iam_instance_profile == null }

  name        = "${each.key}-SSM-Role"
  path        = "/"
  description = "Allows ${each.key} to report to AWS Systems Manager."

  tags = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ssm_profile" {
  for_each = { for k, v in var.instances : k => v if v.iam_instance_profile == null }

  tags = var.tags

  name = "${each.key}-ssm-profile"
  role = aws_iam_role.ssm_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  for_each = { for k, v in var.instances : k => v if v.iam_instance_profile == null }

  role       = aws_iam_role.ssm_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
