data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["*${var.vpc_type}*"]
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*${var.subnet_type}*"]
  }
}

data "aws_subnet" "selected" {
  count = 3
  id    = element(data.aws_subnets.selected.ids, count.index)
}

resource "aws_db_subnet_group" "group" {
  name       = "${var.db_instance_identifier}-rdssubgrp"
  subnet_ids = data.aws_subnets.selected.ids

  tags = merge({ "Name" = "${var.db_instance_identifier}-rdssubgrp" }, var.tags)
}

resource "aws_security_group" "group" {
  name        = "${var.db_instance_identifier}-sg"
  description = "Allow access to RDS SQL services for ${var.db_instance_identifier} instances"
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

  tags = merge({ "Name" = "${var.db_instance_identifier}-sg" }, var.tags)
}

resource "aws_cloudwatch_log_group" "master" {
  for_each = var.enabled_cloudwatch_logs_exports

  name              = "/aws/rds/instance/${var.db_instance_identifier}/${each.value}"
  retention_in_days = var.cloudwatch_logs_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "replica-0" {
  for_each = var.replica_count > 0 ? var.enabled_cloudwatch_logs_exports : []

  name              = "/aws/rds/instance/${var.db_instance_identifier}-replica-0/${each.value}"
  retention_in_days = var.cloudwatch_logs_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "replica-1" {
  for_each = var.replica_count == 2 ? var.enabled_cloudwatch_logs_exports : []

  name              = "/aws/rds/instance/${var.db_instance_identifier}-replica-1/${each.value}"
  retention_in_days = var.cloudwatch_logs_retention_days

  tags = var.tags
}

resource "aws_db_instance" "master" {
  depends_on = [
    aws_cloudwatch_log_group.master
  ]

  db_name        = var.primary_cluster == true && var.snapshot_identifier == null ? var.db_name : null
  engine         = var.db_engine
  engine_version = var.db_engine_version
  license_model  = var.license_model
  timezone       = var.timezone

  identifier            = var.db_instance_identifier
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn
  storage_type          = var.storage_type
  iops                  = var.storage_type == "io1" ? var.iops : null
  copy_tags_to_snapshot = true

  snapshot_identifier = var.snapshot_identifier
  replicate_source_db = var.replicate_source_db

  username             = var.primary_cluster == true && var.snapshot_identifier == null ? var.db_username : null
  password             = var.primary_cluster == true && var.snapshot_identifier == null ? var.db_password : null
  domain               = var.domain
  domain_iam_role_name = var.domain_iam_role

  vpc_security_group_ids = [aws_security_group.group.id]
  db_subnet_group_name   = aws_db_subnet_group.group.id
  availability_zone      = var.multi_az ? data.aws_subnet.selected[0].availability_zone : null
  multi_az               = var.multi_az
  port                   = var.db_port
  publicly_accessible    = false

  apply_immediately    = var.apply_immediately
  option_group_name    = var.option_group_name
  parameter_group_name = var.parameter_group_name

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade

  ca_cert_identifier      = var.ca_cert_identifier
  maintenance_window      = var.maintenance_window
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_retention_period != 0 ? var.backup_window : null

  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  monitoring_interval = var.enable_enh_monitoring == true ? var.enh_monitoring_interval : null
  monitoring_role_arn = var.enable_enh_monitoring == true ? var.enh_monitoring_role_arn : null

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled == true ? var.kms_key_arn : null
  performance_insights_retention_period = var.performance_insights_enabled == true ? var.performance_insights_retention_period : null

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot == false ? "${var.db_instance_identifier}-final-${replace("${timestamp()}", "/[- TZ:]/", "")}" : null
  deletion_protection       = var.enable_deletion_protection
  delete_automated_backups  = var.delete_automated_backups

  tags = merge({ "Name" = "${var.db_instance_identifier}" }, var.tags)

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }
}

resource "aws_db_instance" "replica" {
  count = var.replica_count

  depends_on = [
    aws_cloudwatch_log_group.replica-0
  ]

  license_model = var.license_model
  timezone      = var.timezone

  identifier            = "${var.db_instance_identifier}-replica-${count.index}"
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn
  storage_type          = var.storage_type
  iops                  = var.storage_type == "io1" ? var.iops : null
  copy_tags_to_snapshot = true
  replicate_source_db   = aws_db_instance.master.id

  domain               = var.domain
  domain_iam_role_name = var.domain_iam_role

  vpc_security_group_ids = [aws_security_group.group.id]
  availability_zone      = var.multi_az ? data.aws_subnet.selected[count.index + 1].availability_zone : aws_db_instance.master.availability_zone
  port                   = var.db_port
  publicly_accessible    = false

  apply_immediately    = var.apply_immediately
  option_group_name    = var.option_group_name
  parameter_group_name = var.parameter_group_name

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade

  ca_cert_identifier = var.ca_cert_identifier
  maintenance_window = var.maintenance_window

  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  monitoring_interval = var.enable_enh_monitoring == true ? var.enh_monitoring_interval : null
  monitoring_role_arn = var.enable_enh_monitoring == true ? var.enh_monitoring_role_arn : null

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled == true ? var.kms_key_arn : null
  performance_insights_retention_period = var.performance_insights_enabled == true ? var.performance_insights_retention_period : null

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot == false ? "${var.db_instance_identifier}-final-${replace("${timestamp()}", "/[- TZ:]/", "")}" : null
  deletion_protection       = var.enable_deletion_protection
  delete_automated_backups  = var.delete_automated_backups

  tags = merge({ "Name" = "${var.db_instance_identifier}-replica-${count.index}" }, var.tags)

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }
}
