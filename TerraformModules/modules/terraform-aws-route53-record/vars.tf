variable "records" {
  description = "See object specific arguments in the README."
  type = map(object({
    name    = string
    type    = string
    zone_id = string
    ttl     = string
    records = list(string)

    health_check_id = string
    set_identifier  = string

    multivalue_answer_routing_policy = bool

    alias = object({
      alias_name             = string
      alias_zone_id          = string
      evaluate_target_health = bool
    })
    failover_routing_policy = object({
      type = string
    })
    geolocation_routing_policy = object({
      continent   = string
      country     = string
      subdivision = string
    })
    latency_routing_policy = object({
      region = string
    })
    weighted_routing_policy = object({
      weight = number
    })
  }))
}
