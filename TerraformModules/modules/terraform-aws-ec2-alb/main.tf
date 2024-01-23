# Get VPC
data "aws_region" "current" {}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["*${var.vpc_type}*"]
  }
}

# Get ALB Subnets
data "aws_subnets" "alb" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*${var.alb_subnet_type}*"]
  }
}

data "aws_subnet" "alb" {
  for_each = toset(data.aws_subnets.alb.ids)

  id = each.value
}

# Get target subnets if different
data "aws_subnets" "target" {
  count = var.internal == false ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*${var.target_subnet_type}*"]
  }
}

data "aws_subnet" "target" {
  for_each = var.internal == false ? toset(data.aws_subnets.target[0].ids) : toset([])

  id = each.value
}

resource "aws_security_group" "group" {
  name        = "${var.alb_name}-sg"
  description = "Allow access to ALB services for ${var.alb_name}"
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    for_each = var.redirects
    content {
      from_port   = ingress.value.lb_port
      to_port     = ingress.value.lb_port
      cidr_blocks = ingress.value.ingress_cidr_blocks != null ? ingress.value.ingress_cidr_blocks : ["0.0.0.0/0"]
      protocol    = ingress.value.sg_protocol
      description = ingress.value.description
    }
  }

  dynamic "ingress" {
    for_each = var.listeners
    content {
      from_port   = ingress.value.lb_port
      to_port     = ingress.value.lb_port
      cidr_blocks = ingress.value.ingress_cidr_blocks != null ? ingress.value.ingress_cidr_blocks : ["0.0.0.0/0"]
      protocol    = ingress.value.sg_protocol
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow any to LB subnets"

    cidr_blocks = concat(
      values(data.aws_subnet.alb)[*].cidr_block,
      values(data.aws_subnet.target)[*].cidr_block
    )
  }

  tags = merge({ "Name" = "${var.alb_name}-sg" }, var.tags)
}

resource "aws_lb" "alb" {
  name               = var.alb_name
  enable_http2       = var.enable_http2
  internal           = var.internal
  idle_timeout       = var.idle_timeout
  load_balancer_type = "application"
  subnets            = data.aws_subnets.alb.ids
  security_groups    = ["${aws_security_group.group.id}"]

  access_logs {
    enabled = true
    bucket  = "cbre-region-logs-${data.aws_region.current.name}"
    prefix  = "alb/${var.alb_name}"
  }

  tags = var.tags
}

resource "aws_lb_listener" "redirects" {
  for_each = var.redirects

  load_balancer_arn = aws_lb.alb.arn
  port              = each.value.lb_port
  protocol          = each.value.lb_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = each.value.target_port
      protocol    = each.value.target_protocol
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.alb.arn
  port              = each.value.lb_port
  protocol          = each.value.lb_protocol
  certificate_arn   = each.value.certificate_arn
  ssl_policy        = each.value.ssl_policy

  default_action {
    type             = "forward"
    target_group_arn = var.lb_target_group_arn != null ? var.lb_target_group_arn : aws_lb_target_group.tg[each.key].arn
  }
}

resource "aws_lb_target_group" "tg" {
  for_each = var.lb_target_group_arn != null ? {} : var.listeners

  name        = "${var.alb_name}-${each.key}-tg"
  target_type = var.target_type
  port        = each.value.target_port
  protocol    = each.value.target_protocol
  vpc_id      = data.aws_vpc.selected.id

  deregistration_delay = var.deregistration_delay
  slow_start           = var.slow_start

  health_check {
    enabled             = true
    interval            = each.value.health_check_interval
    path                = each.value.health_check_path
    port                = each.value.health_check_port
    protocol            = each.value.health_check_protocol
    timeout             = each.value.health_check_timeout
    healthy_threshold   = each.value.health_check_healthy_threshold
    unhealthy_threshold = each.value.health_check_unhealthy_threshold
    matcher             = each.value.health_check_matcher
  }

  tags = var.tags

  stickiness {
    enabled         = var.stickness.useStickness
    type            = "lb_cookie"
    cookie_duration = var.stickness.cookie_duration
  }
}

resource "aws_lb_target_group_attachment" "attach" {
  for_each = var.target_ids != null ? local.attachments_map : {}

  target_group_arn = each.value.target_group_arn
  target_id        = each.value.target_id
  port             = each.value.port
}
