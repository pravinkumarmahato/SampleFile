variable "tags" {
  description = "Please reference the current tagging policy for required tags and allowed values.  See README for link to policy."
  type        = map(string)
}

variable "alb_name" {
  description = "The name of the Application ELB (ALB).  This name must be unique per region per account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, must not begin or end with a hyphen, and must not begin with 'internal-'."
  type        = string
}

variable "target_type" {
  description = "The type of target that you must specify when registering targets with this target group. The possible values are 'instance' (targets are specified by instance ID) or 'ip' (targets are specified by IP address) or 'lambda' (targets are specified by lambda arn). Note that you can't specify targets for a target group using both instance IDs and IP addresses. If the target type is ip, specify IP addresses from the subnets of the virtual private cloud (VPC) for the target group, the RFC 1918 range (10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16), and the RFC 6598 range (100.64.0.0/10). You can't specify publicly routable IP addresses."
  type        = string
}

variable "target_ids" {
  description = "The type of target IDs that you must specify when registering targets with this target group. The possible list values are 'instance IDs' ('target_type' is 'instance') or 'IP Addresses' ('target_type' is 'ip') or 'Lambda ARNs' ('target_type' is 'lambda'). This input is not required when using an ASG."
  type        = list(string)
  default     = []
}

variable "vpc_type" {
  description = "The type of vpc to deploy the SG into.  Based on the 'Name' tag on the VPC.  This is case sensitive!"
  type        = string
}

variable "alb_subnet_type" {
  description = "For the ALB, the type of subnet to use based on the 'Name' tag on the subnet.  This will return a map of all subnets (AZs) matching the specified filter. __NOTE:__ When ALB is _not_ 'internal', this input must be set to 'Public' subnets. Example: 'PrivateDynamic', 'Public'"
  type        = string
}

variable "target_subnet_type" {
  description = "For the ALB's targets, the type of subnet to use based on the 'Name' tag on the subnet. This will return a map of all subnets (AZs) matching the specified filter. __NOTE:__ This input is only required when the ALB and targets are in different subnets. For example, when ALB is _not_ 'internal', the ALB will be in 'Public' subnets and the targets will be in 'Private' subnets. When the ALB is 'internal', both the ALB and targets will be in the same subnets and this input can be left 'null'. Example: 'PrivateDynamic', 'PrivateStatic'"
  type        = string
  default     = null
}

variable "deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is '0-3600' seconds."
  type        = number
  default     = 300
}

variable "slow_start" {
  description = "The amount time for targets to warm up before the load balancer sends them a full share of requests. The range is '30-900' seconds or '0' to disable."
  type        = number
  default     = 0
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in application load balancers."
  type        = bool
  default     = true
}

variable "internal" {
  description = "If 'true', ALB will be an internal ALB."
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60
}

variable "redirects" {
  description = "See object specific arguments in the README."
  type = map(object({
    lb_port             = number
    lb_protocol         = string
    ingress_cidr_blocks = list(string)
    target_port         = number
    target_protocol     = string
    sg_protocol         = string
    description         = string
  }))
  default = {}
}

variable "listeners" {
  description = "See object specific arguments in the README."
  type = map(object({
    lb_port             = number
    lb_protocol         = string
    ingress_cidr_blocks = list(string)
    target_port         = number
    target_protocol     = string
    certificate_arn     = string
    sg_protocol         = string
    ssl_policy          = string
    description         = string

    health_check_interval            = number
    health_check_path                = string
    health_check_port                = string
    health_check_protocol            = string
    health_check_timeout             = number
    health_check_healthy_threshold   = number
    health_check_unhealthy_threshold = number
    health_check_matcher             = string
  }))
}

variable "stickness" {
  description = "Definition of sickness for load balancer"
  type = object({
    useStickness    = bool
    cookie_duration = number
  })
  default = {
    useStickness    = false
    cookie_duration = 0
  }
}

variable "lb_target_group_arn" {
  description = "Provide the Loadbalancer target group arn"
  default     = ""
}

locals {
  attachments_list = var.target_ids != null ? flatten([
    for id in var.target_ids : [
      for key in keys(aws_lb_target_group.tg) : {
        target_group_arn = aws_lb_target_group.tg[key].arn
        target_id        = id
        port             = aws_lb_target_group.tg[key].port
      }
    ]
  ]) : null

  attachments_map = var.target_ids != null ? {
    for key, attachment in local.attachments_list :
    key => attachment
  } : null
}
