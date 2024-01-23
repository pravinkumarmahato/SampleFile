# terraform-aws-rds-cluster

## Example Usage

> Generate a strong random password that's safe for PostgreSQL.

```hcl
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
```

> Takes result from random_password and stores in SM.

```hcl
module "db_secret" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-secretsmanager-secrets.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/secretsmanager-secrets/aws"
  version = "<current version>"

  tags = var.tags

  secrets = {
    db_password = {
      secret_name              = "test-db_password"
      secret_description       = "RDS DB password for Test app."
      secret_string            = random_password.db_password.result
      secret_binary            = null
      recovery_window_in_days  = 0
    }
  }
}
```

> Deploy a regional RDS cluster running PostgreSQL with 1 local region Read Replica.

```hcl
module "cluster" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-rds-cluster.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/rds-cluster/aws"
  version = "<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  ## Create from snapshot ##
  snapshot_identifier = null

  ### Global Cluster Configuration ###
  global_cluster_identifier     = null
  primary_cluster               = true
  source_region                 = null
  replication_source_identifier = null

  ### Cluster Configuration ###
  cluster_identifier = "test-cluster"
  database_name      = "test_db"
  master_username    = "cbreadmin"
  master_password    = lookup(module.db_secret.secrets, "db_password")

  engine                = "aurora-postgresql"
  engine_version        = "10.11"
  engine_mode           = "provisioned"
  enable_http_endpoint  = false
  scaling_configuration = {}

  vpc_type      = "DEV"
  subnet_type   = "PrivateRDS"
  port          = null
  kms_key_arn   = module.cmk.key.arn

  ## Aurora Only ##
  backtrack_window = 0
  ## Aurora Only ##

  skip_final_snapshot        = true
  enable_deletion_protection = false

  db_cluster_parameter_group_name     = null
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  cloudwatch_logs_retention_days      = 30
  iam_database_authentication_enabled = false
  iam_roles                           = []

### Instance Configuration ###
  ## Set to 0 for serverless ##
  instance_count = 2
  ## Set to 0 for serverless ##

  instance_class = "db.r5.large"
  promotion_tier = null

  auto_minor_version_upgrade   = true
  db_parameter_group_name      = null
  enable_enh_monitoring        = true
  enh_monitoring_interval      = 15
  enh_monitoring_role_arn      = module.rds_monitoring_role.role.arn
  performance_insights_enabled = true
  ca_cert_identifier           = "rds-ca-2019"

### Global Config ###
  apply_immediately            = false
  preferred_maintenance_window = "Mon:00:00-Mon:03:00"
  backup_retention_period      = 17
  preferred_backup_window      = "04:00-04:30"

  ingress_rules = {
    intrapostgres = {
      from_port       = "5432"
      to_port         = "5432"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = []
      description     = "Allow intra-sg PostgreSQL traffic"
      self            = true
    },
    asg2postgres = {
      from_port       = "5432"
      to_port         = "5432"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.ec2-asg.sg.id]
      description     = "Allow PostgreSQL traffic from ASG"
      self            = false
    }
  }

  egress_rules = {
    any = {
      from_port       = "0"
      to_port         = "0"
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "Allow any outbound"
      self            = false
    }
  }
}
```

### Deploy an Aurora PostgreSQL Global RDS cluster

> RDS global cluster is created in primary region. Primary cluster deployment includes one local region read-replica. Secondary cluster replica is also created in secondary region.

```hcl
provider "aws" {
  alias = "secondary"
  profile = "saml"
  region  = "us-west-2"
  version = "~> 2.59"
}

resource "aws_rds_global_cluster" "db" {
  global_cluster_identifier = "test-global-db"
  database_name             = "test"

  engine         = "aurora-postgresql"
  engine_version = "10.11"

  storage_encrypted   = true
  deletion_protection = false
}

...
Generate password and store in SM
...

module "primary_cluster" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-rds-cluster.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/rds-cluster/aws"
  version = "<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  ## Create from snapshot ##
  snapshot_identifier = null

  ### Global Cluster Configuration ###
  global_cluster_identifier     = aws_rds_global_cluster.db.id
  primary_cluster               = true
  source_region                 = null
  replication_source_identifier = null

  ### Cluster Configuration ###
  cluster_identifier = "test-cluster"
  database_name      = "test_db"
  master_username    = "cbreadmin"
  master_password    = lookup(module.db_secret.secrets, "db_password")

  engine                = "aurora-postgresql"
  engine_version        = "10.11"
  engine_mode           = "provisioned"
  enable_http_endpoint  = false
  scaling_configuration = {}

  vpc_type      = "DEV"
  subnet_type   = "PrivateRDS"
  port          = null
  kms_key_arn   = module.primary_cmk.key.arn

  ## Aurora Only ##
  backtrack_window = 0
  ## Aurora Only ##

  skip_final_snapshot        = true
  enable_deletion_protection = false

  db_cluster_parameter_group_name     = null
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  cloudwatch_logs_retention_days      = 30
  iam_database_authentication_enabled = false
  iam_roles                           = []

### Instance Configuration ###
  instance_count = 2
  instance_class = "db.r5.large"
  promotion_tier = null

  auto_minor_version_upgrade   = true
  db_parameter_group_name      = null
  enable_enh_monitoring        = true
  enh_monitoring_interval      = 15
  enh_monitoring_role_arn      = module.rds_monitoring_role.role.arn
  performance_insights_enabled = true
  ca_cert_identifier           = "rds-ca-2019"

### Global Config ###
  apply_immediately            = false
  preferred_maintenance_window = "Mon:00:00-Mon:03:00"
  backup_retention_period      = 17
  preferred_backup_window      = "04:00-04:30"

  ingress_rules = {
    intrapostgres = {
      from_port       = "5432"
      to_port         = "5432"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = []
      description     = "Allow intra-sg PostgreSQL traffic"
      self            = true
    },
    asg2postgres = {
      from_port       = "5432"
      to_port         = "5432"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.primary_asg.sg.id]
      description     = "Allow PostgreSQL traffic from ASG"
      self            = false
    }
  }

  egress_rules = {
    any = {
      from_port       = "0"
      to_port         = "0"
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "Allow any outbound"
      self            = false
    }
  }
}

module "secondary_cluster" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-rds-cluster.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/rds-cluster/aws"
  version = "<current version>"

  providers = {
    aws = aws.secondary
  }

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  ## Create from snapshot ##
  snapshot_identifier = null

  ### Global Cluster Configuration ###
  global_cluster_identifier     = aws_rds_global_cluster.db.id
  primary_cluster               = false
  source_region                 = "us-east-1"
  replication_source_identifier = module.primary_cluster.cluster.arn

  ### Cluster Configuration ###
  cluster_identifier = "test-cluster"
  database_name      = null
  master_username    = null
  master_password    = null

  engine                = "aurora-postgresql"
  engine_version        = "10.11"
  engine_mode           = "provisioned"
  enable_http_endpoint  = false
  scaling_configuration = {}

  vpc_type      = "DEV"
  subnet_type   = "PrivateRDS"
  port          = null
  kms_key_arn   = module.secondary_cmk.key.arn

  ## Aurora Only ##
  backtrack_window = 0
  ## Aurora Only ##

  skip_final_snapshot        = true
  enable_deletion_protection = false

  db_cluster_parameter_group_name     = null
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  cloudwatch_logs_retention_days      = 30
  iam_database_authentication_enabled = false
  iam_roles                           = []

### Instance Configuration ###
  instance_count = 1
  instance_class = "db.r5.large"
  promotion_tier = null

  auto_minor_version_upgrade   = true
  db_parameter_group_name      = null
  enable_enh_monitoring        = true
  enh_monitoring_interval      = 15
  enh_monitoring_role_arn      = module.rds_monitoring_role.role.arn
  performance_insights_enabled = true
  ca_cert_identifier           = "rds-ca-2019"

### Global Config ###
  apply_immediately            = false
  preferred_maintenance_window = "Mon:00:00-Mon:03:00"
  backup_retention_period      = 17
  preferred_backup_window      = "04:00-04:30"

  ingress_rules = {
    intrapostgres = {
      from_port       = "5432"
      to_port         = "5432"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = []
      description     = "Allow intra-sg PostgreSQL traffic"
      self            = true
    },
    asg2postgres = {
      from_port       = "5432"
      to_port         = "5432"
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.secondary_asg.sg.id]
      description     = "Allow PostgreSQL traffic from ASG"
      self            = false
    }
  }

  egress_rules = {
    any = {
      from_port       = "0"
      to_port         = "0"
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "Allow any outbound"
      self            = false
    }
  }
}
```

### Create an enhanced monitoring role for RDS

> Role gives service `monitoring.rds.amazonaws.com` access to AWS managed policy `AmazonRDSEnhancedMonitoringRole`.

```hcl
module "rds_monitoring_role" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-iam-role.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/iam-role/aws"
  version = "<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  iam_role_name        = "test-rds-monitoring"
  iam_role_path        = "/Example/"
  iam_role_description = "Allows enhanced monitoring of RDS instances."
  permissions_boundary = null
  instance_profile     = false
  iam_managed_policies = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]

  assume_role_policy = [
    {
      effect      = "Allow"
      actions     = ["sts:AssumeRole"]
      not_actions = []
      principals  = {
        EC2 = {
          type        = "Service"
          identifiers = ["monitoring.rds.amazonaws.com"]
        }
      }
      not_principals = {}
      condition      = {}
    }
  ]
}
```

where `<current version>` is the most recent release.

## Related Links

- [CBRE Tagging Policy](https://intranet.cbre.com/Sites/Americas-UnitedStates-DigitalTechnology/en-US/Documents/Digital%20and%20Tech%20Policies/CBRE%20Cloud%20CoE%20Cloud%20Tagging%20Policy.pdf)
- [RDS Naming Constraints](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.Constraints)
- [Aurora MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Updates.html)
- [Aurora Postgres](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Updates.html)
- [RDS User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/aurora-serverless.html)
- [Working with Parameter Groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html)
- [IAM RDS DB Authentication](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.html)
- [Scaling Aurora DB Instances](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Aurora.Managing.html)
- [RDS Instance Classes](https://docs.amazonaws.cn/en_us/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html)

## Object specific arguments

### scaling_configuration

| Name | Description |
|------|-------------|
| `scaling_configuration.key` | Must provide a unique name for the key in the map. Key is only required when `engine_mode` is `serverless`. For example, `scaleconfig`.
| `scaling_configuration.auto_pause` | Whether to enable automatic pause. A DB cluster can be paused only when it's idle (it has no connections). If a DB cluster is paused for more than seven days, the DB cluster might be backed up with a snapshot. In this case, the DB cluster is restored when there is a request to connect to it.
| `scaling_configuration.max_capacity` | The maximum capacity. The maximum capacity must be greater than or equal to the minimum capacity. Valid capacity values are `1`, `2`, `4`, `8`, `16`, `32`, `64`, `128`, and `256`.
| `scaling_configuration.min_capacity` | The minimum capacity. The minimum capacity must be lesser than or equal to the maximum capacity. Valid capacity values are `1`, `2`, `4`, `8`, `16`, `32`, `64`, `128`, and `256`.
| `scaling_configuration. seconds_until_auto_pause` | The time, in seconds, before an Aurora DB cluster in serverless mode is paused. Valid values are `300` through `86400`.
| `scaling_configuration.timeout_action` | The action to take when the timeout is reached. Valid values: `ForceApplyCapacityChange`, `RollbackCapacityChange`. See [documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html#aurora-serverless.how-it-works.timeout-action) for more information.

### ingress_rules

| Name | Description |
|------|-------------|
| `ingress_rules.key` | Must provide a unique name for each key in the map. For example, `internal`.
| `ingress_rules.from_port` | The start port (or ICMP type number if protocol is "icmp").
| `ingress_rules.to_port` | The end range port (or ICMP code if protocol is "icmp").
| `ingress_rules.protocol` | The protocol(s) for which to allow inbound traffic. Example: `-1` (all), `tcp`, `udp`, `icmp`.  If `-1` is used, the corresponding `from_port` and `to_port` must be `0`.  If a protocol other than tcp, udp, or icmp is desired, you must use the [protocol number](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml#protocol-numbers-1).
| `ingress_rules.cidr_blocks` | List of CIDR blocks for which to allow inbound traffic.
| `ingress_rules.security_groups` | List of security group IDs for which to allow inbound traffic.
| `ingress_rules.description` | Description for the security group rule.
| `ingress_rules.self` | If `true`, the security group itself will be added as a source to this ingress rule.

### egress_rules

| Name | Description |
|------|-------------|
| `egress_rules.key` | Must provide a unique name for each key in the map. For example, `any`.
| `egress_rules.from_port` | The start port (or ICMP type number if protocol is "icmp").
| `egress_rules.to_port` | The end range port (or ICMP code if protocol is "icmp").
| `egress_rules.protocol` | The protocol(s) for which to allow outbound traffic. Example: `-1` (all), `tcp`, `udp`, `icmp`.  If `-1` is used, the corresponding `from_port` and `to_port` must be `0`.  If a protocol other than tcp, udp, or icmp is desired, you must use the [protocol number](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml#protocol-numbers-1).
| `egress_rules.cidr_blocks` | List of CIDR blocks for which to allow outbound traffic.
| `egress_rules.security_groups` | List of security group IDs for which to allow outbound traffic.
| `egress_rules.description` | Description for the security group rule.
| `egress_rules.self` | If `true`, the security group itself will be added as a source to this egress rule.

## Development

Feel free to create a branch and submit a pull request to make changes to the module.

## License

Copyright: 2023, CBRE Group, Inc., All Rights Reserved.
