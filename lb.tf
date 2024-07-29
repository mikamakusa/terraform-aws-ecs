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
  security_groups                  = []
  subnets                          = []
  tags                             = {}

  dynamic "access_logs" {
    for_each = lookup(var.aws_lb[count.index], "access_logs") == null ? [] : ["access_logs"]
    content {
      bucket  = ""
      enabled = true
      prefix  = ""
    }
  }

  dynamic "subnet_mapping" {
    for_each = lookup(var.aws_lb[count.index], "subnet_mapping") == null ? [] : ["subnet_mapping"]
    content {
      subnet_id            = ""
      allocation_id        = ""
      ipv6_address         = ""
      private_ipv4_address = ""
    }
  }
}

resource "aws_lb_target_group" "this" {
  connection_termination             = ""
  deregistration_delay               = ""
  ip_address_type                    = ""
  lambda_multi_value_headers_enabled = true
  load_balancing_algorithm_type      = ""
  name                               = ""
  name_prefix                        = ""
  port                               = 0
  preserve_client_ip                 = ""
  protocol                           = ""
  protocol_version                   = ""
  proxy_protocol_v2                  = true
  slow_start                         = true
  tags                               = {}
  target_type                        = ""
  vpc_id                             = ""

  dynamic "health_check" {
    for_each = ""
    content {
      enabled             = true
      healthy_threshold   = 0
      interval            = 0
      matcher             = ""
      path                = ""
      port                = ""
      protocol            = ""
      timeout             = 0
      unhealthy_threshold = 0
    }
  }

  dynamic "stickiness" {
    for_each = ""
    content {
      type            = ""
      cookie_duration = 0
      cookie_name     = ""
      enabled         = true
    }
  }
}