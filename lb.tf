resource "aws_lb" "this" {
  count                            = length(var.aws_lb)
  customer_owned_ipv4_pool         = lookup(var.aws_lb[count.index], "customer_owned_ipv4_pool")
  desync_mitigation_mode           = lookup(var.aws_lb[count.index], "desync_mitigation_mode")
  drop_invalid_header_fields       = lookup(var.aws_lb[count.index], "drop_invalid_header_fields")
  enable_cross_zone_load_balancing = lookup(var.aws_lb[count.index], "enable_cross_zone_load_balancing")
  enable_deletion_protection       = lookup(var.aws_lb[count.index], "enable_deletion_protection")
  enable_http2                     = lookup(var.aws_lb[count.index], "enable_http2")
  enable_waf_fail_open             = lookup(var.aws_lb[count.index], "enable_waf_fail_open")
  idle_timeout                     = lookup(var.aws_lb[count.index], "idle_timeout")
  internal                         = lookup(var.aws_lb[count.index], "internal")
  ip_address_type                  = lookup(var.aws_lb[count.index], "ip_address_type")
  load_balancer_type               = lookup(var.aws_lb[count.index], "load_balancer_type")
  name                             = lookup(var.aws_lb[count.index], "name")
  name_prefix                      = lookup(var.aws_lb[count.index], "name_prefix")
  preserve_host_header             = lookup(var.aws_lb[count.index], "preserve_host_header")
  security_groups                  = [
    try(
      element(aws_security_group.this.*.id, lookup(var.aws_lb[count.index], "security_groups_id"))
    )
  ]
  subnets                          = [
    try(
      element(aws_subnet.this.*.id, lookup(var.aws_lb[count.index], "subnets_id"))
    )
  ]
  tags                             = merge(
    var.tags,
    lookup(var.aws_lb[count.index], "tags"),
    data.aws_default_tags.this.tags
  )

  dynamic "access_logs" {
    for_each = lookup(var.aws_lb[count.index], "access_logs") == null ? [] : ["access_logs"]
    content {
      bucket = try(
        element(aws_s3_bucket.this.*.id, lookup(access_logs.value, "bucket_id"))
      )
      enabled = lookup(access_logs.value, "enabled")
      prefix  = lookup(access_logs.value, "prefix")
    }
  }

  dynamic "subnet_mapping" {
    for_each = lookup(var.aws_lb[count.index], "subnet_mapping") == null ? [] : ["subnet_mapping"]
    content {
      subnet_id = try(
        element(aws_subnet.this.*.id, lookup(subnet_mapping.value, "subnet_id"))
      )
      allocation_id        = lookup(subnet_mapping.value, "allocation_id")
      ipv6_address         = lookup(subnet_mapping.value, "ipv6_address")
      private_ipv4_address = lookup(subnet_mapping.value, "private_ipv6_address")
    }
  }
}

resource "aws_lb_target_group" "this" {
  count                              = length(var.lb_target_group)
  connection_termination             = lookup(var.lb_target_group[count.index], "connection_termination")
  deregistration_delay               = lookup(var.lb_target_group[count.index], "deregistration_delay")
  ip_address_type                    = lookup(var.lb_target_group[count.index], "ip_address_type")
  lambda_multi_value_headers_enabled = lookup(var.lb_target_group[count.index], "lambda_multi_value_headers_enabled")
  load_balancing_algorithm_type      = lookup(var.lb_target_group[count.index], "load_balancing_algorithm_type")
  name                               = lookup(var.lb_target_group[count.index], "name")
  name_prefix                        = lookup(var.lb_target_group[count.index], "name_prefix")
  port                               = lookup(var.lb_target_group[count.index], "port")
  preserve_client_ip                 = lookup(var.lb_target_group[count.index], "preserve_client_ip")
  protocol                           = lookup(var.lb_target_group[count.index], "protocol")
  protocol_version                   = lookup(var.lb_target_group[count.index], "protocol_version")
  proxy_protocol_v2                  = lookup(var.lb_target_group[count.index], "proxy_protocol_v2")
  slow_start                         = lookup(var.lb_target_group[count.index], "slow_start")
  tags                               = merge(
    var.tags,
    lookup(var.lb_target_group[count.index], "tags"),
    data.aws_default_tags.this.tags
  )
  target_type                        = lookup(var.lb_target_group[count.index], "target_type")
  vpc_id                             = data.aws_vpc.this.id

  dynamic "health_check" {
    for_each = lookup(var.lb_target_group[count.index], "health_check") == null ? [] : ["health_check"]
    content {
      enabled             = lookup(health_check.value, "enabled")
      healthy_threshold   = lookup(health_check.value, "healthy_threshold")
      interval            = lookup(health_check.value, "interval")
      matcher             = lookup(health_check.value, "matcher")
      path                = lookup(health_check.value, "path")
      port                = lookup(health_check.value, "port")
      protocol            = lookup(health_check.value, "protocol")
      timeout             = lookup(health_check.value, "timeout")
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold")
    }
  }

  dynamic "stickiness" {
    for_each = lookup(var.lb_target_group[count.index], "stickiness") == null ? [] : ["stickiness"]
    content {
      type            = lookup(stickiness.value, "type")
      cookie_duration = lookup(stickiness.value, "cookie_duration")
      cookie_name     = lookup(stickiness.value, "cookie_name")
      enabled         = lookup(stickiness.value, "enabled")
    }
  }
}