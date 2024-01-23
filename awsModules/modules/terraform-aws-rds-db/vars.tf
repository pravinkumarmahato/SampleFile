variable "tags" {
  description = "Please reference the current tagging policy for required tags and allowed values.  See README for link to policy."
  type        = map(string)
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console."
  type        = string
  default     = null
}

variable "primary_cluster" {
  description = "Designates whether or not this RDS cluster is a Primary or Read Replica. NOTE: If creating a Read Replica and set to 'false', you must also provide 'replicate_source_db'."
  type        = bool
  default     = false
}

variable "replicate_source_db" {
  description = "Specifies that this resource is a cross-region Read Replica DB, and to use this ARN as the source database. This correlates to the 'ARN' of another Amazon RDS DB master to replicate from a different region. NOTE: Removing the 'replicate_source_db' attribute from an existing RDS Replica database managed by Terraform will promote the database to a fully standalone database."
  type        = string
  default     = null
}

variable "db_instance_identifier" {
  description = "The name to use for the DB instance(s). Named will be used to interpolate naming of Read Replica(s) and supporting resources. Please ensure that the name is unique per AWS account, per AWS Region, for example by including the 'Environment' in the name. Must contain 1 to 63 alphanumeric characters or hyphens, start with a letter and cannot end with a hyphen or contain two consecutive hyphens."
  type        = string
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created. Database name constraints differ for each database engine. For more information, see the available settings when creating each DB instance. NOTE: This is required unless 'snapshot_identifier' or 'replicate_source_db' is provided."
  type        = string
  default     = null
}

variable "db_engine" {
  description = "The database engine to use. For supported values, see 'RDS Engine Options' in related links.  This is required unless a 'snapshot_identifier' or 'replicate_source_db' is provided."
  type        = string
  default     = null
}

variable "db_engine_version" {
  description = "If 'auto_minor_version_upgrade' is enabled, you can provide a prefix of the version such as 5.7 (for 5.7.10) and this attribute will ignore differences in the patch version automatically (e.g. 5.7.17). Set to 'null' to use the RDS default."
  type        = string
  default     = null
}

variable "license_model" {
  description = "License model information for this DB instance.  Optional, but required for some DB engines, i.e. MSSQL."
  type        = string
  default     = null
}

variable "timezone" {
  description = "Time zone of the DB instance. 'timezone' is currently only supported by Microsoft SQL Server."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The instance type of the RDS instance. See 'RDS Instance Classes' in related links."
  type        = string
}

variable "vpc_type" {
  description = "The type of vpc to deploy into based on the 'Name' tag on the VPC.  This is case sensitive!"
  type        = string
}

variable "subnet_type" {
  description = "The type of subnet to use based on the 'Name' tag on the subnet.  This will return a map of all subnets (AZs) matching the specified filter.  Example: 'PrivateRDS'"
  type        = string
}

variable "db_port" {
  description = "The port on which the DB accepts connections.  Set to 'null' to use the RDS default."
  type        = number
  default     = null
}

variable "multi_az" {
  description = "Specifies if the master RDS instance is multi-AZ. The standby replica in a Multi-AZ deployment cannot take on read requests. It is only meant for a failover (HA) and is not used for read purposes."
  type        = bool
  default     = true
}

variable "replica_count" {
  description = "Number of RDS DB read replicas to deploy. Can have a maximum of '2' read replicas."
  type        = number
  default     = 0
}

variable "allocated_storage" {
  description = "The allocated storage in gibibytes.  This is required unless a 'snapshot_identifier' or 'replicate_source_db' is provided. Minimum required value is '20'."
  type        = string
}

variable "max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to 'allocated_storage'. Must be greater than or equal to 'allocated_storage' or '0' to disable Storage Autoscaling."
  type        = number
  default     = null
}

variable "storage_type" {
  description = "The type of storage to use for the database. Example: 'standard', 'gp2', 'io1'. Defaults: 'io1' if 'iops' is specified, 'gp2' if not."
  type        = string
  default     = "gp2"
}

variable "iops" {
  description = "The amount of provisioned IOPS. This is required if 'storage_type' is set to 'io1'."
  type        = number
  default     = null
}

variable "kms_key_arn" {
  description = "Amazon CMK ARN for KMS key used for Amazon S3 server side encryption. This value must be an AWS CMK ARN and not an ID or alias."
  type        = string
  default     = null
}

variable "db_username" {
  description = "Username for the master DB user. Please refer to the 'RDS Naming Constraints' in related links. NOTE: This is required unless 'snapshot_identifier' is provided or not 'primary_cluster'."
  type        = string
  default     = null
}

variable "db_password" {
  description = "Password for the master DB user. This is input is required only when 'primary_cluster'. NOTE: This is required unless 'snapshot_identifier' is provided or not 'primary_cluster'."
  type        = string
  default     = null
}

variable "domain" {
  description = "The ID of the Directory Service Active Directory domain to create the instance in."
  type        = string
  default     = null
}

variable "domain_iam_role" {
  description = "(Optional, but required if 'domain' is provided) The name of the IAM role to be used when making API calls to the Directory Service."
  type        = string
  default     = null
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "option_group_name" {
  description = "Name of the DB option group to associate. See 'Working with Option Groups' in related links."
  type        = string
  default     = null
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate. See 'Working with Parameter Groups' in related links."
  type        = string
  default     = null
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance."
  type        = string
  default     = "rds-ca-2019"
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Example: 'Mon:00:00-Mon:03:00'."
  type        = string
  default     = "Mon:00:00-Mon:00:30"
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Must be between '0' and '35'. Set to '0' to disable backups. NOTE: Backups must be enabled if deploying an RDS DB as a replication master (source). Backups must be disabled if deploying a Read Replica and 'replicate_source_db' is provided."
  type        = number
  default     = 0
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with 'maintenance_window'. Only required if 'backup_retention_period > 0'."
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): 'alert', 'audit', 'error', 'general', 'listener', 'slowquery', 'trace'. Valid values for PostgreSQL: 'postgresql', 'upgrade'."
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
  type        = bool
  default     = false
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
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Only required if 'enh_monitoring_interval > 0'."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled."
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data. Either '7' (7 days) or '731' (2 years). Only required if 'performance_insights_enabled = true'."
  type        = number
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If 'true' is specified, no DBSnapshot is created. If 'false' is specified, a DB snapshot is created before the DB instance is deleted, using the value from 'final_snapshot_identifier'."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to 'true'."
  type        = bool
  default     = false
}

variable "delete_automated_backups" {
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted."
  type        = bool
  default     = true
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
