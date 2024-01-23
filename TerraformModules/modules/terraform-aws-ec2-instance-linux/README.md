# terraform-aws-ec2-instance-linux

## Example Usage

```hcl
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "linuxinstance" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-ec2-instance-linux.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/ec2-instance-linux/aws"
  version = "<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  instances = {
    USAWSE1GHEX01 = {
      availability_zone     = "a"
      custodian_offhours    = "off=[(M-F,17)];on=[(M-F,9)];tz=ct"
      enable_recovery_alarm = true
      iam_instance_profile  = null
      instance_type         = "m5.large"
      os_volume_size        = 20
      os_volume_type        = "gp2"
      user_data             = data.template_cloudinit_config.USAWSE1GHEX01.rendered
    }
    USAWSE1GHEX02 = {
      availability_zone     = "b"
      custodian_offhours    = "off=[(M-F,17)];on=[(M-F,9)];tz=ct"
      enable_recovery_alarm = true
      iam_instance_profile  = null
      instance_type         = "m5.large"
      os_volume_size        = 20
      os_volume_type        = "gp2"
      user_data             = data.template_cloudinit_config.USAWSE1GHEX02.rendered
    }
  }

  vpc_type           = "DEV"
  subnet_type        = "PrivateDynamic"
  ami_id             = data.aws_ami.ami.id
  keypair_public_key = "ssh-rsa XXXXXXXXXX example-key"
  key_name           = null

  security_group_ids = null

  ingress_rules = {
    internal = {
      from_port       = "0"
      to_port         = "0"
      protocol        = "-1"
      cidr_blocks     = ["10.0.0.0/8", "172.16.0.0/12"]
      security_groups = []
      description     = "Allow all internal traffic inbound"
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

where `<current version>` is the most recently tagged version.

## Related Links

- [CBRE Tagging Policy](https://cbre.sharepoint.com/:b:/r/sites/intra-DigitalTechnology/Shared%20Documents/Internal%20D%26T%20Standards%20%26%20Procedures/Cloud%20Tagging%20Standard.pdf?csf=1&web=1&e=yqXCpK)
- [puttygen on Windows](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/create-with-putty/)
- [ssh-keygen on macOS/Linux](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/create-with-openssh/)
- [ssh-keygen Conversion](https://tutorialinux.com/convert-ssh2-openssh/)
- [AWS Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [AWS EBS Volume Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html)
- [Custodian Offhours](https://confluence.cbre.com/display/CLOUD/Custodian+EC2+Offhours)

## Object specific arguments

### instances

| Name | Description |
|------|-------------|
| `instances.availability_zone` | The availability zone to place the instance in. For example, `a`.
| `instances.custodian_offhours` | Defines the schedule for automatic instance startup and shutdown.  Must be in the following format: `off=[(M-F,18)];on=[(M-F,6)];tz=cst`.  Set this to `null` to disable offhours.  See Related Links above for `Custodian Offhours`.
| `instances.enable_recovery_alarm` | If `true`, the module will create a CloudWatch recovery alarm which will automatically restart the instance if the underlying hardware fails.  **Enabling this can cause downtime if your deployment is not set up for HA.**
| `instances.iam_instance_profile` | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile (not the ARN). Ensure your credentials have the correct permission to assign the instance profile according to the EC2 documentation, notably `iam:PassRole`.  Example: `MyService-InstanceProfile`.  Set this to `null` to use the default instance profile.
| `instances.instance_type` | The type of instance to deploy.  Example: `t2.small`, `m5.large`, `c4.xlarge`. See Related Links above for `AWS Instance Types`.
| `instances.os_volume_size` | The size of the OS volume in GBs.
| `instances.os_volume_type` | The type of volume to use.  Example: `gp2`, `io1`, `st1`. See Related Links above for `AWS EBS Volume Types`.
| `instances.user_data` | The user data to provide when launching this instance.  Set this to `null` to provide no user data.

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

Copyright: 2022, CBRE Group, Inc., All Rights Reserved.
