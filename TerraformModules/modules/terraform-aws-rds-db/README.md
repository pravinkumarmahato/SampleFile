# terraform-aws-rds-db

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

> Use a data source to look up an existing KMS key for RDS encryption.

data "aws_kms_alias" "test" {
  name = "alias/cbre-cmk/test"
}

> Deploy a mult-az RDS classic PostgreSQL DB with 1 local region Read Replica.

```hcl
module "primary_db" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-rds-db.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/rds-db/aws"
  version = "<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  ## Create from snapshot ##
  snapshot_identifier = null

  ## Create from source DB master instance ##
  primary_cluster     = true
  replicate_source_db = null

  ### RDS DB Configuration ###
  db_instance_identifier = "test-db"
  db_name                = "test_db"

  db_engine         = "postgres"
  db_engine_version = "11.5"
  license_model     = null
  timezone          = null
  instance_class    = "db.m5.large"
  vpc_type          = "DEV"
  subnet_type       = "PrivateRDS"
  db_port           = null

  ## Create master failover replica (non-read) ##
  multi_az = true

  ## Can have a max of 2 Read Replicas ##
  replica_count = 1

  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp2"
  iops                  = null
  kms_key_arn           = data.aws_kms_alias.test.target_key_arn

  db_username     = "cbreadmin"
  db_password     = lookup(module.db_secret.secrets, "db_password")
  domain          = null
  domain_iam_role = null

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = false
  option_group_name           = null
  parameter_group_name        = null

  ca_cert_identifier      = "rds-ca-2019"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_retention_period = 17
  backup_window           = "04:00-04:30"

  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  cloudwatch_logs_retention_days      = 30
  iam_database_authentication_enabled = false

  enable_enh_monitoring   = true
  enh_monitoring_interval = 15
  enh_monitoring_role_arn = module.rds_monitoring_role.role.arn

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  skip_final_snapshot        = true
  enable_deletion_protection = false
  delete_automated_backups   = true

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
      security_groups = [module.ec2-asg_primary.sg.id]
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

### Deploy a mult-az RDS classic PostgreSQL DB with DR

> Master is set to multi-az for failover and includes one local region read-replica. Read-replica is also created in secondary region.

```hcl
provider "aws" {
  profile = "your_aws_credentials_profile"
  region  = "us-east-1"
  alias   = "primary"
}

provider "aws" {
  profile = "your_aws_credentials_profile"
  region  = "us-west-2"
  alias   = "secondary"
}

module "primary_db" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-rds-db.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/rds-db/aws"
  version = "<current version>"

  providers = {
    aws = aws.primary
  }

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  ## Create from snapshot ##
  snapshot_identifier = null

  ## Create from source DB master instance ##
  primary_cluster     = true
  replicate_source_db = null

  ### RDS DB Configuration ###
  db_instance_identifier = "test-db"
  db_name                = "test_db"

  db_engine         = "postgres"
  db_engine_version = "11.5"
  license_model     = null
  timezone          = null
  instance_class    = "db.m5.large"
  vpc_type          = "DEV"
  subnet_type       = "PrivateRDS"
  db_port           = null

  ## Create master failover replica (non-read) ##
  multi_az = true

  ## Can have a max of 2 Read Replicas ##
  replica_count = 1

  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp2"
  iops                  = null
  kms_key_arn           = null

  db_username     = "cbreadmin"
  db_password     = lookup(module.db_secret.secrets, "db_password")
  domain          = null
  domain_iam_role = null

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = false
  option_group_name           = null
  parameter_group_name        = null

  ca_cert_identifier      = "rds-ca-2019"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_retention_period = 17
  backup_window           = "04:00-04:30"

  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  cloudwatch_logs_retention_days      = 30
  iam_database_authentication_enabled = false

  enable_enh_monitoring   = true
  enh_monitoring_interval = 15
  enh_monitoring_role_arn = module.rds_monitoring_role.role.arn

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  skip_final_snapshot        = true
  enable_deletion_protection = false
  delete_automated_backups   = true

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
      security_groups = [module.ec2-asg_primary.sg.id]
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

module "secondary_db" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-rds-db.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/rds-db/aws"
  version = "<current version>"

  providers = {
    aws = aws.secondary
  }

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  ## Create from source DB master instance ##
  primary_cluster     = false
  replicate_source_db = module.rds_primary.db_instance_master.arn

  ### RDS DB Configuration ###
  db_instance_identifier = "test-db"

  db_engine_version = "11.5"
  license_model     = null
  timezone          = null
  instance_class    = "db.m5.large"
  vpc_type          = "PROD"
  subnet_type       = "PrivateRDS"
  db_port           = null

  ## Create primary failover replica (non-read) ##
  multi_az = false

  ## Can have a max of 2 Read Replicas ##
  replica_count = 0

  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp2"
  iops                  = null
  kms_key_arn           = null

  domain          = null
  domain_iam_role = null

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = false
  option_group_name           = null
  parameter_group_name        = null

  ca_cert_identifier      = "rds-ca-2019"
  maintenance_window      = "Mon:00:00-Mon:03:00"

  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  cloudwatch_logs_retention_days      = 30
  iam_database_authentication_enabled = false

  enable_enh_monitoring   = true
  enh_monitoring_interval = 15
  enh_monitoring_role_arn = module.rds_monitoring_role.role.arn

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  skip_final_snapshot        = true
  enable_deletion_protection = false
  delete_automated_backups   = true

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
      security_groups = [module.ec2-asg_secondary.sg.id]
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
- [RDS Instance Classes](https://docs.amazonaws.cn/en_us/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html)
- [Working with Option Groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithOptionGroups.html)
- [Working with Parameter Groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html)
- [IAM RDS DB Authentication](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.html)

## Object specific arguments

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

Copyright: 2021, CBRE Group, Inc., All Rights Reserved.
