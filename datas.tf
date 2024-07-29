data "aws_autoscaling_group" "this" {
  count = var.autoscaling_group_name ? 1 : 0
  name  = var.autoscaling_group_name
}

data "aws_default_tags" "this" {}

data "aws_lb_target_group" "this" {
  count = var.lb_target_group_name ? 1 : 0
  id    = var.lb_target_group_name
}

data "aws_lb" "this" {
  count = var.aws_lb ? 1 : 0
  id    = var.aws_lb
}

data "aws_service_discovery_service" "this" {
  count        = var.aws_service_discovery_service_name ? 1 : 0
  name         = var.aws_service_discovery_service_name
  namespace_id = var.aws_service_discovery_service_namespace
}

data "aws_acmpca_certificate_authority" "this" {
  count = var.aws_acmpca_certificate_authority_arn ? 1 : 0
  arn   = var.aws_acmpca_certificate_authority_arn
}

data "aws_vpc" "this" {
  count = var.vpc_id ? 1 : 0
  id    = var.vpc_id
}