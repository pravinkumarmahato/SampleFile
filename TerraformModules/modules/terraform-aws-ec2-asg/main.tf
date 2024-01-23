resource "aws_key_pair" "keypair" {
  count = var.key_name == null ? 1 : 0

  key_name   = "${var.asg_name}-kp"
  public_key = var.keypair_public_key

  tags = var.tags
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["*${var.vpc_type}*"]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*${var.subnet_type}*"]
  }
}

data "aws_iam_role" "asg" {
  name = "AWSServiceRoleForAutoScaling_CBRE-CMK"
}

resource "aws_security_group" "sg" {
  count = var.security_groups == null ? 1 : 0

  name        = "${var.asg_name}-sg"
  description = "Allow access to instances in ASG ${var.asg_name}"
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

  tags = merge({ "Name" = "${var.asg_name}-sg" }, var.tags)
}

resource "aws_launch_template" "lt" {
  name = "${var.lt_name}-${replace(timestamp(), "/[- TZ:]/", "")}"

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", null) == null ? [] : ["ebs"]
        content {
          delete_on_termination = lookup(block_device_mappings.value.ebs, "delete_on_termination", null)
          encrypted             = lookup(block_device_mappings.value.ebs, "encrypted", null)
          iops                  = lookup(block_device_mappings.value.ebs, "iops", null)
          kms_key_id            = lookup(block_device_mappings.value.ebs, "kms_key_id", null)
          snapshot_id           = lookup(block_device_mappings.value.ebs, "snapshot_id", null)
          volume_size           = lookup(block_device_mappings.value.ebs, "volume_size", null)
          volume_type           = lookup(block_device_mappings.value.ebs, "volume_type", null)
        }
      }
    }
  }

  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.ebs_optimized

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != "" ? [var.iam_instance_profile] : []
    content {
      name = iam_instance_profile.value
    }
  }

  image_id                             = var.ami_id
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
    content {
      market_type = lookup(instance_market_options.value, "market_type", null)

      dynamic "spot_options" {
        for_each = (instance_market_options.value.spot_options != null ?
        [instance_market_options.value.spot_options] : [])
        content {
          block_duration_minutes         = lookup(spot_options.value, "block_duration_minutes", null)
          instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
          max_price                      = lookup(spot_options.value, "max_price", null)
          spot_instance_type             = lookup(spot_options.value, "spot_instance_type", null)
          valid_until                    = lookup(spot_options.value, "valid_until", null)
        }
      }
    }
  }

  instance_type = var.instance_type
  key_name      = var.key_name == null ? aws_key_pair.keypair[0].key_name : var.key_name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  vpc_security_group_ids = var.security_groups == null ? [aws_security_group.sg[0].id] : var.security_groups

  dynamic "tag_specifications" {
    for_each = var.tag_specifications_resource_types

    content {
      resource_type = tag_specifications.value
      tags          = merge({ "Name" = var.lt_name }, var.tags)
    }
  }

  tags = var.tags
  user_data = format("%s\n%s", base64encode(templatefile("${path.module}/General_user_data.sh", {
    environment        = upper(var.tags.Environment)
    server_domain      = var.server_domain
    server_admin_group = var.server_admin_group
    role_name          = var.role_name
  })), var.user_data)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  # Interpolating the LC name into the ASG name here causes any changes that
  # would replace the LC (like, most commonly, an AMI ID update) to _also_
  # replace the ASG.
  name             = "${var.asg_name}-on-${aws_launch_template.lt.name}"
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  default_cooldown    = var.default_cooldown
  placement_group     = var.placement_group
  vpc_zone_identifier = data.aws_subnets.subnets.ids
  load_balancers      = var.load_balancers
  target_group_arns   = var.target_group_arns
  enabled_metrics     = var.enabled_metrics

  service_linked_role_arn   = data.aws_iam_role.asg.arn
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  termination_policies = var.termination_policies
  suspended_processes  = var.suspended_processes

  min_elb_capacity      = var.min_elb_capacity
  wait_for_elb_capacity = var.wait_for_elb_capacity
  protect_from_scale_in = var.protect_from_scale_in
  max_instance_lifetime = var.max_instance_lifetime

  launch_template {
    id      = aws_launch_template.lt.id
    version = aws_launch_template.lt.latest_version
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
