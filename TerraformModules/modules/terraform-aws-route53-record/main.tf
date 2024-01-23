resource "aws_route53_record" "record" {
  for_each = var.records

  name    = each.value.name
  type    = each.value.type
  zone_id = each.value.zone_id
  ttl     = each.value.ttl
  records = each.value.records

  health_check_id = each.value.health_check_id
  set_identifier  = each.value.set_identifier

  multivalue_answer_routing_policy = each.value.multivalue_answer_routing_policy

  dynamic "alias" {
    for_each = each.value.alias != null ? [1] : []

    content {
      name    = each.value.alias.alias_name
      zone_id = each.value.alias.alias_zone_id

      evaluate_target_health = each.value.alias.evaluate_target_health
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [1] : []

    content {
      type = each.value.failover_routing_policy.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation_routing_policy != null ? [1] : []

    content {
      continent   = each.value.geolocation_routing_policy.continent
      country     = each.value.geolocation_routing_policy.country
      subdivision = each.value.geolocation_routing_policy.subdivision
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [1] : []

    content {
      region = each.value.latency_routing_policy.region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [1] : []

    content {
      weight = each.value.weighted_routing_policy.weight
    }
  }

  allow_overwrite = false
}
