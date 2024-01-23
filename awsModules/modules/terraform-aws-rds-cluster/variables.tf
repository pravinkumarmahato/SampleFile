variable "tags" {
  description = "Please reference the current tagging policy for required tags and allowed values.  See README for link to policy."
  type        = map(string)
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
  type        = string
  default     = null
}

variable "global_cluster_identifier" {
  description = "The global cluster identifier specified on 'aws_rds_global_cluster'. Must be created separately using 'aws_rds_global_cluster' resource. See example in README."
  type        = string
  default     = null
}

variable "primary_cluster" {
  description = "For Global clusters, designates whether or not this RDS cluster is a Primary or Read Replica. NOTE: If creating a Read Replica and set to 'false', you must also provide 'source_region' and 'replication_source_identifier'."
  type        = bool
  default     = false
}

variable "source_region" {
  description = "For Global clusters, the source region for an encrypted replica DB cluster. NOTE: If not 'primary_cluster', this input is required."
  type        = string
  default     = null
}

variable "replication_source_identifier" {
  description = "For Global clusters, ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. NOTE: If not 'primary_cluster', this input is required."
  type        = string
  default     = null
}

variable "cluster_identifier" {
  description = "The name of the RDS Aurora cluster. Please ensure that the name is unique, for example by including the Environment in the name. Must be lowercase, contain 1 to 63 alphanumeric characters or hyphens, start with a letter and cannot end with a hyphen or contain two consecutive hyphens."
  type        = string
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation. There are different naming restrictions per database engine: See 'RDS Naming Constraints' in related links. NOTE: This is required unless 'snapshot_identifier' is provided or not 'primary_cluster'."
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user. Please refer to the 'RDS Naming Constraints' in related links. This argument does not support in-place updates and cannot be changed during a restore from snapshot. NOTE: This is required unless 'snapshot_identifier' is provided or not 'primary_cluster'."
  type        = string
  default     = null
}

variable "master_password" {
  description = "Password for the master DB user. This is input is required only when 'primary_cluster'. NOTE: This is required unless 'snapshot_identifier' is provided or not 'primary_cluster'."
  type        = string
  default     = null
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster. Valid Values: 'aurora' (Aurora MySQL 1.x (MySQL 5.6)), 'aurora-mysql' (Aurora MySQL 2.x (MySQL 5.7)), 'aurora-postgresql'."
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage. See the 'Aurora MySQL' and 'Aurora Postgres' related links for your configured engine to determine this value. For example with Aurora MySQL 2, a potential value for this argument is '5.7.mysql_aurora.2.03.2'."
  type        = string
  default     = null
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: 'global', 'multimaster', 'parallelquery', 'provisioned', 'serverless'. See the 'RDS User Guide' in related links for limitations when using 'serverless'. Must be set to 'global' for an Aurora MySQL global cluster or 'provisioned' for an Aurora PostgreSQL global cluster."
  type        = string
  default     = "provisioned"
}

variable "enable_http_endpoint" {
  description = "Enable HTTP endpoint (data API). Only valid when engine_mode is set to 'serverless'."
  type        = string
  default     = false
}

variable "scaling_configuration" {
  description = "Nested object with scaling properties. Only valid when engine_mode is set to 'serverless'. See object specific arguments in the README."
  type = map(object({
    auto_pause               = bool
    max_capacity             = number
    min_capacity             = number
    seconds_until_auto_pause = number
    timeout_action           = string
  }))
  default = {}
}

variable "vpc_type" {
  description = "The type of vpc to deploy into based on the 'Name' tag on the VPC.  This is case sensitive!"
  type        = string
}

variable "subnet_type" {
  description = "The type of subnet to use based on the 'Name' tag on the subnet.  This will return a map of all subnets (AZs) matching the specified filter.  Example: 'PrivateRDS'"
  type        = string
}

variable "port" {
  description = "The port on which the DB accepts connections.  Set to 'null' to use the RDS default."
  type        = number
  default     = null
}

variable "kms_key_arn" {
  description = "Amazon CMK ARN for KMS key used for Amazon S3 server side encryption. This value must be an AWS CMK ARN and not an ID or alias."
  type        = string
  default     = null
}

variable "backtrack_window" {
  description = "The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set value to '0'. Must be between '0' and '259200' (72 hours)."
  type        = number
  default     = 0
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to 'true'."
  type        = bool
  default     = false
}

variable "db_cluster_parameter_group_name" {
  description = "Name of the Cluster parameter group to associate. See 'Working with Parameter Groups' in related links."
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported for Aurora or Aurora MySQL: 'audit', 'error', 'general', 'slowquery'. The following log types are supported for Aurora PostgreSQL: 'postgresql'."
  type        = set(string)
  default     = []
}

variable "cloudwatch_logs_retention_days" {
  description = "Specifies the number of days you want to retain log events for the RDS cluster. Possible values are: '1', '3', '5', '7', '14', '30', '60', '90', '120', '150', '180', '365', '400', '545', '731', '1827', and '3653'. Input is ignored if 'enabled_cloudwatch_logs_exports' is set to 'null'."
  type        = number
  default     = 3
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. Please see 'IAM RDS DB Authentication' in related links for availability and limitations."
  type        = string
  default     = false
}

variable "iam_roles" {
  description = "A List of ARNs for the IAM roles to associate to the RDS Cluster."
  type        = list(string)
  default     = []
}

variable "instance_count" {
  description = "Number of cluster instances to deploy. Must set to '0' for 'serverless'."
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "The instance class to use. For details on CPU and memory, see 'Scaling Aurora DB Instances' in related links. Aurora uses 'db.*' instance classes/types. Please see 'RDS Instance Classes' in related links for currently available instance classes and complete details."
  type        = string
}

variable "promotion_tier" {
  description = "Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoted to writer."
  type        = number
  default     = 0
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = true
}

variable "db_parameter_group_name" {
  description = "Name of the DB parameter group to associate. See 'Working with Parameter Groups' in related links."
  type        = string
  default     = null
}

variable "enable_enh_monitoring" {
  description = "Specify whether or not to enable enhanced monitoring."
  type        = bool
  default     = true
}

variable "enh_monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify '0'."
  type        = number
  default     = 0
}

variable "enh_monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled."
  type        = bool
  default     = false
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance."
  type        = string
  default     = "rds-ca-2019"
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "preferred_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Example: 'Mon:00:00-Mon:03:00'."
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Must be between '0' and '35'. When creating a Read Replica the value must be greater than '0'.  Set to '0' to disable backups."
  type        = number
  default     = 0
}

variable "preferred_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'."
  type        = string
  default     = "04:00-04:30"
}

variable "ingress_rules" {
  description = "See object specific arguments in the README."
  type = map(object({
    from_port       = string
    to_port         = string
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
    description     = string
    self            = bool
  }))
  default = {}
}

variable "egress_rules" {
  description = "See object specific arguments in the README."
  type = map(object({
    from_port       = string
    to_port         = string
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
    description     = string
    self            = bool
  }))
  default = {}
}
