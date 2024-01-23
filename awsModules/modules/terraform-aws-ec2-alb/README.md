# terraform-aws-ec2-alb

## Example Usage

```hcl
module "alb" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-ec2-alb.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/ec2-alb/aws"
  version = "<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  alb_name             = "example-alb"
  target_type          = "instance"
  target_ids           = module.linuxinstance.instance[*].id
  vpc_type             = "DEV"
  alb_subnet_type      = "Public"
  target_subnet_type   = "PrivateStatic"
  lb_target_group_arn  = var.lb_target_group_arn ## Please use this variable if you want to pass existing target group to the listener.
  deregistration_delay = 300
  slow_start           = 0
  enable_http2         = true
  internal             = false
  idle_timeout         = 60

  redirects = {
    http2https = {
      lb_port             = 80
      lb_protocol         = "HTTP"
      ingress_cidr_blocks = null
      target_port         = 443
      target_protocol     = "HTTPS"
      sg_protocol         = "tcp"
      description         = "Redirect HTTP to HTTPS"
    }
  }

  listeners = {
    https = {
      lb_port             = 443
      lb_protocol         = "HTTPS"
      ingress_cidr_blocks = null
      target_port         = 443
      target_protocol     = "HTTPS"
      certificate_arn     = "<your_cert_arn>"
      sg_protocol         = "tcp"
      ssl_policy          = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
      description         = "Public HTTPS to example app"

      health_check_interval            = 30
      health_check_path                = "/_health_check"
      health_check_port                = "traffic-port"
      health_check_protocol            = "HTTPS"
      health_check_timeout             = 5
      health_check_healthy_threshold   = 3
      health_check_unhealthy_threshold = 3
      health_check_matcher             = "200"
    }
  }

  /* Following is optional, by default no cookie_stickiness_policy is created */
  stickness = {
    useStickness = true
    cookie_duration = 120
  }
}
```

where `<current version>` is the most recent release.

## Related Links

- [CBRE Tagging Policy](https://intranet.cbre.com/Sites/Americas-UnitedStates-DigitalTechnology/en-US/Documents/Digital%20and%20Tech%20Policies/CBRE%20Cloud%20CoE%20Cloud%20Tagging%20Policy.pdf)
- [ELB SSL Policies](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies)

## Object specific arguments

### redirects

| Name | Description |
|------|-------------|
| `redirects.key` | Must provide a unique name for each key in the map. For example, `http2https`.
| `redirects.lb_port` | The port on which the load balancer is listening that will be redirected.
| `redirects.lb_protocol` | The protocol for connections from clients to the load balancer that will be redirected. Valid values are `TCP`, `TLS`, `UDP`, `TCP_UDP`, `HTTP` and `HTTPS`.
| `redirects.ingress_cidr_blocks` | List of CIDR blocks for which to allow inbound traffic.
| `redirects.target_port` | The redirected port on which targets receive traffic.
| `redirects.target_protocol` | The redirected protocol to use for routing traffic to the targets. Should be one of `TCP`, `TLS`, `UDP`, `TCP_UDP`, `HTTP` or `HTTPS`.
| `redirects.sg_protocol` | The protocol. If you select a protocol of `-1` (semantically equivalent to "all", which is not a valid value here), you must specify a `from_port` and `to_port` equal to `0`. If not `icmp`, `tcp`, `udp`, or `-1` use the protocol number.
| `redirects.description` | Description for the security group rule.

### listeners

| Name | Description |
|------|-------------|
| `listeners.key` | Must provide a unique name for each key in the map. For example, `https`. The key will also be used to name the target groups.
| `listeners.lb_port` | The port on which the load balancer is listening.
| `listeners.lb_protocol` | The protocol for connections from clients to the load balancer. Valid values are `TCP`, `TLS`, `UDP`, `TCP_UDP`, `HTTP` and `HTTPS`.
| `listeners.ingress_cidr_blocks` | List of CIDR blocks for which to allow inbound traffic.
| `listeners.target_port` | The port on which targets receive traffic, unless overridden when registering a specific target. Required when `target_type` is `instance` or `ip`. Does not apply when `target_type` is `lambda`.
| `listeners.target_protocol` | The protocol to use for routing traffic to the targets. Should be one of `TCP`, `TLS`, `UDP`, `TCP_UDP`, `HTTP` or `HTTPS`. Required when `target_type` is `instance` or `ip`. Does not apply when `target_type` is `lambda`.
| `listeners.certificate_arn` | The ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is `HTTPS`. For adding additional SSL certificates, see the [aws_lb_listeners_certificate resource](https://www.terraform.io/docs/providers/aws/r/lb_listeners_certificate.html).
| `listeners.sg_protocol` | The protocol. If you select a protocol of `-1` (semantically equivalent to "all", which is not a valid value here), you must specify a `from_port` and `to_port` equal to `0`. If not `icmp`, `tcp`, `udp`, or `-1` use the protocol number.
| `listeners.description` | Description for the security group rule.
| `listeners.ssl_policy` | The name of the SSL Policy for the listener. Required if protocol is `HTTPS` or `TLS`. See related links above for available policies.
| `listeners.health_check_interval` | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. For lambda target groups, it needs to be greater as the timeout of the underlying lambda.
| `listeners.health_check_path` | **(Required for HTTP/HTTPS ALB)** The destination for the health check request. Applies to Application Load Balancers only (HTTP/HTTPS), not Network Load Balancers (TCP). | string | | yes |
| `listeners.health_check_port` | The port to use to connect with the target. Valid values are either ports `1-65536`, or `traffic-port`.
| `listeners.health_check_protocol` | The protocol to use to connect with the target. Not applicable when target_type is `lambda`.
| `listeners.health_check_timeout` | The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is `2` to `120` seconds, and the default is 5 seconds for the instance target type and 30 seconds for the lambda target type. For Network Load Balancers, you cannot set a custom value, and the default is 10 seconds for TCP and HTTPS health checks and 6 seconds for HTTP health checks.
| `listeners.health_check_healthy_threshold` | The number of consecutive health checks successes required before considering an unhealthy target healthy.
| `listeners.health_check_unhealthy_threshold` | The number of consecutive health check failures required before considering the target unhealthy . For Network Load Balancers, this value must be the same as the `healthy_threshold`.

### Load Balancer Stickness - Optional Parameters

| Name | Description |
|------|-------------|
| `stickness.useStickness` | By default this is false.  Determines if the policy needs to be added to the target group
| `stickness.cookie_duration` | The length of time the cookies exist on the load balancer.


## Development

Feel free to create a branch and submit a pull request to make changes to the module.

## License

Copyright: 2021, CBRE Group, Inc., All Rights Reserved.
