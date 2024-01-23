# terraform-aws-ec2-asg

## Example Usage

```hcl

data "aws_ami" "ami" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

module "ec2-asg" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-ec2-asg.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/ec2-asg/aws"
  version = "<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

   asg_name              = "example-frontend"
   lt_name               = "example-application"
   keypair_public_key    = "ssh-rsa XXXXXXXXXX example-key"
   key_name              = null
   user_data             = data.template_cloudinit_config.config.rendered
   ami_id                = data.aws_ami.ami.id
   vpc_type              = "DEV"
   subnet_type           = "PrivateDynamic"
   instance_type         = "m5.large"
   security_groups       = null
   os_volume_size        = "50"
   os_volume_type        = "gp2"
   enable_monitoring     = true
   spot_price            = null
   placement_tenancy     = "default"

  iam_instance_profile        = null
  associate_public_ip_address = false
  role_name                   = "General_Linux"
  server_domain               = "US"

  block_device_mappings = {
    "data-volume" = {
      device_name  = "/dev/sdb"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        kms_key_id            = aws_kms_key.default.id
        volume_size           = 8
        volume_type           = "gp2"
      }
    }
  }

### Autoscale Configuration ###
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  default_cooldown  = 300
  placement_group   = null
  load_balancers    = []
  target_group_arns = module.alb.tgs[*].arn
  enabled_metrics   = null

  health_check_grace_period = 300
  health_check_type         = "EC2"
  wait_for_capacity_timeout = "10m"

  termination_policies = null
  suspended_processes  = null

  ## Custom Options ##
  min_elb_capacity      = null
  wait_for_elb_capacity = null
  protect_from_scale_in = false
  max_instance_lifetime = null

  ingress_rules = {
    internal = {
      from_port       = "0"
      to_port         = "0"
      protocol        = "-1"
      cidr_blocks     = ["10.0.0.0/8"]
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

where `<current version>` is the most recent release.

## Related Links

- [CBRE Tagging Policy](https://intranet.cbre.com/Sites/Americas-UnitedStates-DigitalTechnology/en-US/Documents/Digital%20and%20Tech%20Policies/CBRE%20Cloud%20CoE%20Cloud%20Tagging%20Policy.pdf)
- [puttygen on Windows](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/create-with-putty/)
- [ssh-keygen on macOS/Linux](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/create-with-openssh/)
- [ssh-keygen Conversion](https://tutorialinux.com/convert-ssh2-openssh/)
- [AWS Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [AWS EBS Volume Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html)
- [AWS's Create Launch Configuration](http://docs.aws.amazon.com/AutoScaling/latest/APIReference/API_CreateLaunchConfiguration.html)

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

### block_device_mappings

| Name | Description |
|------|-------------|
| `block_device_mappings.key` | Must provide a unique name for each key in the map. For example, `data-volume`.
| `block_device_mappings.device_name` | Name of the block device. For example `/dev/sdf`
| `block_device_mappings.no_device` | The start port (or ICMP type number if protocol is "icmp").
| `block_device_mappings.virtual_name` | The end range port (or ICMP code if protocol is "icmp").
| `block_device_mappings.ebs.delete_on_termination` | Whether to delete this volume on instance termination.
| `block_device_mappings.ebs.encrypted` | Whether the volume needs to be encrypted.
| `block_device_mappings.ebs.iops` | Provisioned IOPS for the volume. Applies only when volume type is io1/io2.
| `block_device_mappings.ebs.kms_key_id` | KMS key id to encrypt the volume. If not mentioned it will be encrypted by CBRE KMS key
| `block_device_mappings.ebs.snapshot_id` | Snapshot ID to mount.
| `block_device_mappings.ebs.volume_size` | Size of the volume.
| `block_device_mappings.ebs.volume_type` | Type of volume standard, gp2, gp3, io1, io2, sc1 or st1.

### instance_market_options

| Name | Description |
|------|-------------|
| `instance_market_options.market_type` | The market type. Can be spot.
| `instance_market_options.spot_options.block_duration_minutes` | The required duration in minutes. This value must be a multiple of 60
| `instance_market_options.spot_options.instance_interruption_behavior` | The behavior when a Spot Instance is interrupted. Can be hibernate, stop, or terminate.
| `instance_market_options.spot_options.max_price` | The maximum hourly price you're willing to pay for the Spot Instances.
| `instance_market_options.spot_options.spot_instance_type` | The Spot Instance request type. Can be one-time, or persistent.
| `instance_market_options.spot_options.valid_until` | The end date of the request.


## Development

Feel free to create a branch and submit a pull request to make changes to the module.

## License

Copyright: 2021, CBRE Group, Inc., All Rights Reserved.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_key_pair.keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.lt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI ID to use in this scale set | `string` | n/a | yes |
| <a name="input_asg_name"></a> [asg\_name](#input\_asg\_name) | A name for the ASG that will be rendered and used to name all deployed resources. | `string` | n/a | yes |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to deploy.  Example: 't2.small', 'm5.large', 'c4.xlarge'. See related links for 'AWS Instance Types'. | `string` | n/a | yes |
| <a name="input_lt_name"></a> [lt\_name](#input\_lt\_name) | A name for the ASG's launch template. This name will be interpolated into the ASG so they are tied together for all TF operations. | `string` | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the auto scale group. | `string` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the auto scale group. | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The role of the server.  Allowed values are 'General\_Linux | `string` | n/a | yes |
| <a name="input_subnet_type"></a> [subnet\_type](#input\_subnet\_type) | The type of subnet to use based on the 'Name' tag on the subnet.  This will return a map of all subnets (AZs) matching the specified filter.  Example: 'PrivateStatic', 'PrivateDynamic' | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Please reference the current tagging policy for required tags and allowed values.  See README for link to policy. | `map(string)` | n/a | yes |
| <a name="input_vpc_type"></a> [vpc\_type](#input\_vpc\_type) | The type of vpc to deploy into.  Based on the 'Name' tag on the VPC.  This is case sensitive! | `string` | n/a | yes |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | <pre>map(object({<br>    device_name  = string<br>    no_device    = optional(bool)<br>    virtual_name = optional(string)<br>    ebs = object({<br>      delete_on_termination = bool<br>      encrypted             = bool<br>      iops                  = optional(number)<br>      kms_key_id            = optional(string)<br>      snapshot_id           = optional(string)<br>      volume_size           = number<br>      volume_type           = string<br>    })<br>  }))</pre> | `{}` | no |
| <a name="input_default_cooldown"></a> [default\_cooldown](#input\_default\_cooldown) | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start. | `number` | `300` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If `true`, enables EC2 Instance Termination Protection | `bool` | `true` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | Whether or not EBS optimization is needed | `bool` | `false` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | See object specific arguments in the README. | <pre>map(object({<br>    from_port       = string<br>    to_port         = string<br>    protocol        = string<br>    cidr_blocks     = list(string)<br>    security_groups = list(string)<br>    description     = string<br>    self            = bool<br>  }))</pre> | `{}` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enables/disables detailed monitoring. | `bool` | `true` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | A list of metrics to collect. The allowed values are 'GroupDesiredCapacity', 'GroupInServiceCapacity', 'GroupPendingCapacity', 'GroupMinSize', 'GroupMaxSize', 'GroupInServiceInstances', 'GroupPendingInstances', 'GroupStandbyInstances', 'GroupStandbyCapacity', 'GroupTerminatingCapacity', 'GroupTerminatingInstances', 'GroupTotalCapacity', 'GroupTotalInstances'. | `list(string)` | <pre>[<br>  "GroupDesiredCapacity",<br>  "GroupInServiceCapacity",<br>  "GroupPendingCapacity",<br>  "GroupMinSize",<br>  "GroupMaxSize",<br>  "GroupInServiceInstances",<br>  "GroupPendingInstances",<br>  "GroupStandbyInstances",<br>  "GroupStandbyCapacity",<br>  "GroupTerminatingCapacity",<br>  "GroupTerminatingInstances",<br>  "GroupTotalCapacity",<br>  "GroupTotalInstances"<br>]</pre> | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time (in seconds) after instance comes into service before checking health. | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | 'EC2 or 'ELB'. Controls how health checking is done. | `string` | `"EC2"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The IAM Instance Profile to launch the instance with. Specified as the Name of the Instance Profile (not the ARN). Ensure your credentials have the correct permission to assign the instance profile according to the EC2 documentation, notably 'iam:PassRole'. | `string` | `null` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | See object specific arguments in the README. | <pre>map(object({<br>    from_port       = string<br>    to_port         = string<br>    protocol        = string<br>    cidr_blocks     = list(string)<br>    security_groups = list(string)<br>    description     = string<br>    self            = bool<br>  }))</pre> | `{}` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instance | `string` | `"stop"` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | The market (purchasing) option for the instances | <pre>object({<br>    market_type = string<br>    spot_options = optional(object({<br>      block_duration_minutes         = optional(number)<br>      instance_interruption_behavior = optional(string)<br>      max_price                      = optional(number)<br>      spot_instance_type             = optional(string)<br>      valid_until                    = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The key name of an existing Key Pair to use for the instance(s). Only use if 'keypair\_public\_key' is not supplied. Useful when sharing a Key Pair across multiple instances/deployments. | `string` | `null` | no |
| <a name="input_keypair_public_key"></a> [keypair\_public\_key](#input\_keypair\_public\_key) | Public key to be used for guest OS authentication.  This can be generated by 'puttygen on Windows' or 'ssh-keygen on macOS/Linux'. The SSH2 Public Key needs to be converted into an OpenSSH Public Key format RFC4716 which is the required format for this input. On Windows, use puttygen to Load your new private key, then copy the ssh-rsa public key string from the text box at the top of the window. Use 'ssh-keygen Conversion' to convert to an ssh-rsa string. | `string` | `null` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers (ELB). For ALBs, use 'target\_group\_arns' instead. | `list(string)` | `[]` | no |
| <a name="input_max_instance_lifetime"></a> [max\_instance\_lifetime](#input\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to '0' or between '604800' and '31536000' seconds. | `string` | `null` | no |
| <a name="input_min_elb_capacity"></a> [min\_elb\_capacity](#input\_min\_elb\_capacity) | Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes. | `string` | `null` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | The name of the placement group into which you'll launch your instances, if any. | `string` | `null` | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events. | `string` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of existing security groups to attach this instance to.  If specified, no security group will be created as part of this module. | `list(string)` | `null` | no |
| <a name="input_server_admin_group"></a> [server\_admin\_group](#input\_server\_admin\_group) | The group that will need admin rights to the system.  Must be sepcified as 'GROUP@domain'. | `string` | `"US_INF-GEP-CloudAdmins@us.cbre.net"` | no |
| <a name="input_server_domain"></a> [server\_domain](#input\_server\_domain) | The domain with which to join. | `string` | `"US"` | no |
| <a name="input_suspended_processes"></a> [suspended\_processes](#input\_suspended\_processes) | A list of processes to suspend for the AutoScaling Group. The allowed values are 'Launch', 'Terminate', 'HealthCheck', 'ReplaceUnhealthy', 'AZRebalance', 'AlarmNotification', 'ScheduledActions', 'AddToLoadBalancer'. Note that if you suspend either the 'Launch' or 'Terminate' process types, it can prevent your autoscaling group from functioning properly. | `list(string)` | `[]` | no |
| <a name="input_tag_specifications_resource_types"></a> [tag\_specifications\_resource\_types](#input\_tag\_specifications\_resource\_types) | List of tag specification resource types to tag. Valid values are instance, volume, elastic-gpu and spot-instances-request. | `set(string)` | <pre>[<br>  "instance",<br>  "volume"<br>]</pre> | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | A list of 'aws\_alb\_target\_group' ARNs, for use with Application or Network Load Balancing. | `list(string)` | `[]` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are 'OldestInstance', 'NewestInstance', 'OldestLaunchConfiguration', 'ClosestToNextInstanceHour', 'OldestLaunchTemplate', 'AllocationStrategy', 'Default'. | `list(string)` | `[]` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance. | `string` | `""` | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |
| <a name="input_wait_for_elb_capacity"></a> [wait\_for\_elb\_capacity](#input\_wait\_for\_elb\_capacity) | Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations. (Takes precedence over 'min\_elb\_capacity' behavior.) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg"></a> [asg](#output\_asg) | The 'aws\_autoscaling\_group.ec2-asg' resource. |
| <a name="output_lt"></a> [lt](#output\_lt) | The 'aws\_launch\_template.lt' resource. |
| <a name="output_sg"></a> [sg](#output\_sg) | The 'aws\_security\_group.sg' resource. |
<!-- END_TF_DOCS -->