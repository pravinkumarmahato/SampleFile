data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = [
      "*${var.vpc_type}*"
    ]
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

data "aws_subnet" "subnets" {
  for_each = toset(data.aws_subnets.subnets.ids)

  id = each.value
}

resource "aws_db_subnet_group" "group" {
  name       = "${var.cluster_identifier}-rdssubgrp"
  subnet_ids = data.aws_subnets.subnets.ids

  tags = merge(
    {
      "Name" = "${var.cluster_identifier}-rdssubgrp"
    },
    var.tags
  )
}

resource "aws_security_group" "group" {
  name        = "${var.cluster_identifier}-sg"
  description = "Allow access to RDS SQL services for ${var.cluster_identifier} instances"
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

  tags = merge(
    {
      "Name" = "${var.cluster_identifier}-sg"
    },
    var.tags
  )
}


resource "aws_cloudwatch_log_group" "rdscluster" {
  for_each = var.enabled_cloudwatch_logs_exports

  name              = "/aws/rds/cluster/${var.cluster_identifier}/${each.value}"
  retention_in_days = var.cloudwatch_logs_retention_days

  tags = var.tags
}

resource "aws_rds_cluster" "cluster" {
  depends_on = [
    aws_cloudwatch_log_group.rdscluster
  ]

  global_cluster_identifier     = var.global_cluster_identifier
  replication_source_identifier = var.replication_source_identifier
  source_region                 = var.primary_cluster == false && var.global_cluster_identifier != null ? var.source_region : null

  cluster_identifier  = var.cluster_identifier
  database_name       = var.primary_cluster == true && var.snapshot_identifier == null ? var.database_name : null
  master_username     = var.primary_cluster == true && var.snapshot_identifier == null ? var.master_username : null
  master_password     = var.primary_cluster == true && var.snapshot_identifier == null ? var.master_password : null
  snapshot_identifier = var.snapshot_identifier

  engine               = var.engine
  engine_version       = var.engine_version
  engine_mode          = var.engine_mode
  enable_http_endpoint = var.enable_http_endpoint

  dynamic "scaling_configuration" {
    for_each = var.scaling_configuration
    content {
      auto_pause               = scaling_configuration.value.auto_pause
      max_capacity             = scaling_configuration.value.max_capacity
      min_capacity             = scaling_configuration.value.min_capacity
      seconds_until_auto_pause = scaling_configuration.value.seconds_until_auto_pause
      timeout_action           = scaling_configuration.value.timeout_action
    }
  }

  vpc_security_group_ids = [aws_security_group.group.id]
  db_subnet_group_name   = aws_db_subnet_group.group.name
  availability_zones     = values(data.aws_subnet.subnets)[*].availability_zone
  port                   = var.port
  copy_tags_to_snapshot  = true
  storage_encrypted      = true
  kms_key_id             = var.kms_key_arn

  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = var.preferred_maintenance_window
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  backtrack_window             = var.backtrack_window

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot == false ? "${var.cluster_identifier}-final-${replace("${timestamp()}", "/[- TZ:]/", "")}" : null
  deletion_protection       = var.enable_deletion_protection

  db_cluster_parameter_group_name     = var.db_cluster_parameter_group_name
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles

  tags = merge(
    {
      "cluster_identifier" = "${var.cluster_identifier}",
      "database_name"      = "${var.database_name}"
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }
}

resource "aws_rds_cluster_instance" "instance" {
  count = var.instance_count

  cluster_identifier = aws_rds_cluster.cluster.id
  identifier         = "${var.cluster_identifier}-node-${count.index}"
  instance_class     = var.instance_class
  engine             = var.engine
  engine_version     = var.engine_version
  promotion_tier     = var.promotion_tier

  db_subnet_group_name  = aws_db_subnet_group.group.name
  availability_zone     = element(values(data.aws_subnet.subnets)[*].availability_zone, count.index)
  publicly_accessible   = false
  copy_tags_to_snapshot = true

  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = var.preferred_maintenance_window

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  db_parameter_group_name    = var.db_parameter_group_name

  monitoring_interval = var.enable_enh_monitoring == true ? var.enh_monitoring_interval : null
  monitoring_role_arn = var.enable_enh_monitoring == true ? var.enh_monitoring_role_arn : null

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled == true ? var.kms_key_arn : null

  tags = merge(
    {
      "Name" = "${var.cluster_identifier}-node-${count.index}"
    },
    var.tags
  )
}
