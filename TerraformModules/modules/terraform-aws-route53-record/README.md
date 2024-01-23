# terraform-aws-route53-record

## Example Usage

### Create a host (A) record

> A lookup is performed to get the Route53 zone and then an A record is created.

```hcl
data "aws_route53_zone" "selected" {
  name         = "example.com."
  private_zone = false
}

module "record" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-route53-record.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/route53-record/aws"
  version = "<current version>"

  records = {
    app_example_com = {
      name    = "app.example.com"
      type    = "A"
      zone_id = data.aws_route53_zone.selected.zone_id
      ttl     = "300"
      records = [module.instance.instance[0].private_ip]

      health_check_id = null
      set_identifier  = null

      multivalue_answer_routing_policy = null

      alias                      = null
      failover_routing_policy    = null
      geolocation_routing_policy = null
      latency_routing_policy     = null
      weighted_routing_policy    = null
    }
  }
}
```

### Create a host (A) record with an AWS service alias

> A lookup is performed to get the Route53 zone and then an A record with alias is created.

```hcl
data "aws_route53_zone" "selected" {
  name         = "example.com."
  private_zone = false
}

module "record" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-route53-record.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/route53-record/aws"
  version = "<current version>"

  records = {
    app_example_com = {
      name    = "app.example.com"
      type    = "A"
      zone_id = data.aws_route53_zone.selected.zone_id
      ttl     = null
      records = null

      health_check_id = null
      set_identifier  = null

      multivalue_answer_routing_policy = false

      alias = {
        alias_name             = module.alb.alb.dns_name
        alias_zone_id          = module.alb.alb.zone_id
        evaluate_target_health = false
      }

      failover_routing_policy    = null
      geolocation_routing_policy = null
      latency_routing_policy     = null
      weighted_routing_policy    = null
    }
  }
}
```

### Create two alias host (A) record with automatic region failover

> A lookup is performed to get the Route53 zone and then two alias A records are created with `failover_routing_policy`.

```hcl
data "aws_route53_zone" "selected" {
  name         = "example.com."
  private_zone = false
}

module "record_a" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-route53-record.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/route53-record/aws"
  version = "<current version>"

  records = {
    app_example_com = {
      name    = "app.example.com"
      type    = "A"
      zone_id = data.aws_route53_zone.selected.zone_id
      ttl     = null
      records = null

      health_check_id = null
      set_identifier  = "primary"

      multivalue_answer_routing_policy = false

      alias = {
        alias_name             = module.alb_primary.alb.dns_name
        alias_zone_id          = module.alb_primary.alb.zone_id
        evaluate_target_health = true
      }

      failover_routing_policy = {
        type = "PRIMARY"
      }

      geolocation_routing_policy = null
      latency_routing_policy     = null
      weighted_routing_policy    = null
    }
  }
}

module "record_b" {
  ## If using from Github directly
  source = "github.com/CBRE-Shared-Code/terraform-aws-route53-record.git?ref=<current version>"

  ## If using Terraform Enterprise
  source  = "tfe.cloudeng.cbre.com/cbre/route53-record/aws"
  version = "<current version>"

  records = {
    app_example_com = {
      name    = "app.example.com"
      type    = "A"
      zone_id = data.aws_route53_zone.selected.zone_id
      ttl     = null
      records = null

      health_check_id = null
      set_identifier  = "secondary"

      multivalue_answer_routing_policy = false

      alias = {
        alias_name             = module.alb_secondary.alb.dns_name
        alias_zone_id          = module.alb_secondary.alb.zone_id
        evaluate_target_health = true
      }

      failover_routing_policy = {
        type = "SECONDARY"
      }

      geolocation_routing_policy = null
      latency_routing_policy     = null
      weighted_routing_policy    = null
    }
  }
}
```

where `<current version>` is the most recent release.

## Related Links

- [CBRE Tagging Policy](https://intranet.cbre.com/Sites/Americas-UnitedStates-DigitalTechnology/en-US/Documents/Digital%20and%20Tech%20Policies/CBRE%20Cloud%20CoE%20Cloud%20Tagging%20Policy.pdf)

## Object specific arguments

### records

| Name | Description |
|------|-------------|
| `records.key` | Must provide a unique name for each key in the map. For example, `app.example.com`.
| `records.name` | The name of the record. For example, `app.example.com`.
| `records.type` | The record type. Valid values are `A`, `AAAA`, `CAA`, `CNAME`, `MX`, `NAPTR`, `NS`, `PTR`, `SOA`, `SPF`, `SRV` and `TXT`.
| `records.zone_id` | The ID of the hosted zone to contain this record.
| `records.ttl` | The TTL of the record. __NOTE:__ This input is required for _non-alias_ records.
| `records.records` | A string list of records. To specify a single record value longer than 255 characters such as a `TXT` record for DKIM, add `\"\"` inside the Terraform configuration string (e.g. `"first255characters\"\"morecharacters"`). __NOTE:__ This input is required for _non-alias_ records.
| `records.health_check_id` | The health check the record should be associated with.
| `records.set_identifier` | Unique identifier to differentiate records with routing policies from one another. Required if using `failover`, `geolocation`, `latency`, or `weighted` routing policy objects described below.
| `records.multivalue_answer_routing_policy` | Set to `true` to indicate a multivalue answer routing policy. Conflicts with any other routing policy and must be set to `null` if not used.

### records.alias

| Name | Description |
|------|-------------|
| `records.alias` | An alias block. Conflicts with inputs `ttl` and `records`. Alias record documented below.
| `records.alias.alias_name` | DNS domain name for a CloudFront distribution, S3 bucket, ELB, or another resource record set in this hosted zone.
| `records.alias.alias_zone_id` | Hosted zone ID for a CloudFront distribution, S3 bucket, ELB, or Route 53 hosted zone.
| `records.alias.evaluate_target_health` | Set to `true` if you want Route 53 to determine whether to respond to DNS queries using this resource record set by checking the health of the resource record set. Some resources have special requirements, see [related part of documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values.html#rrsets-values-alias-evaluate-target-health).

### records.failover

| Name | Description |
|------|-------------|
| `records.failover_routing_policy` | A block indicating the routing behavior when associated health check fails. Conflicts with any other routing policy. Documented below.
| `records.failover_routing_policy.type` | `PRIMARY` or `SECONDARY`. A `PRIMARY` record will be served if its healthcheck is passing, otherwise the `SECONDARY` will be served. See [documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-types.html#dns-failover-types-active-passive-one-resource) for configuring DNS failover.

### records.geolocation_routing_policy

| Name | Description |
|------|-------------|
| `records.geolocation_routing_policy` | A block indicating a routing policy based on the geolocation of the requestor. Conflicts with any other routing policy. Documented below.
| `records.geolocation_routing_policy.continent` | A two-letter continent code. See [documentation](https://docs.aws.amazon.com/Route53/latest/APIReference/API_GetGeoLocation.html) for code details.
| `records.geolocation_routing_policy.country` | A two-character country code or `*` to indicate a default resource record set. See [documentation](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) for code details.
| `records.geolocation_routing_policy.subdivision` | A subdivision code for a country. See [documentation](https://pe.usps.com/text/pub28/28apb.htm) for code details.

### records.latency_routing_policy

| Name | Description |
|------|-------------|
| `records.latency_routing_policy` | A block indicating a routing policy based on the latency between the requestor and an AWS region. Conflicts with any other routing policy. Documented below.
| `records.latency_routing_policy.region` | An AWS region from which to measure latency. See [documentation](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-latency) for latency policy details.

### records.weighted_routing_policy

| Name | Description |
|------|-------------|
| `records.weighted_routing_policy` | A block indicating a weighted routing policy. Conflicts with any other routing policy. Documented below.
| `records.weighted_routing_policy.weight` | A numeric value indicating the relative weight of the record. See [documentation](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-weighted) for weighted policy details.

## Development

Feel free to create a branch and submit a pull request to make changes to the module.

## License

Copyright: 2021, CBRE Group, Inc., All Rights Reserved.
