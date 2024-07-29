resource "aws_autoscaling_group" "this" {
  max_size = 0
  min_size = 0
  availability_zones = []
  capacity_rebalance = true
  default_cooldown = 0
  desired_capacity = 0
  enabled_metrics = []
  force_delete = true
  health_check_grace_period = 0
  health_check_type = ""
  launch_configuration = ""
  max_instance_lifetime = 0
  metrics_granularity = ""
  min_elb_capacity = 0
  name = ""
  name_prefix = ""
  placement_group = ""
  protect_from_scale_in = true
  service_linked_role_arn = ""
  suspended_processes = []
  target_group_arns = []
  termination_policies = []
  vpc_zone_identifier = []
  wait_for_capacity_timeout = ""
  wait_for_elb_capacity = 0


  dynamic "instance_refresh" {
    for_each = ""
    content {
      strategy = ""
      triggers = []

      dynamic "preferences" {
        for_each = ""
        content {}
      }
    }
  }

  dynamic "launch_template" {
    for_each = ""
    content {}
  }

  dynamic "mixed_instances_policy" {
    for_each = ""
    content {}
  }

  dynamic "initial_lifecycle_hook" {
    for_each             = ""
    content {
      lifecycle_transition = ""
      name                 = ""
    }
  }

  dynamic "tag" {
    for_each            = ""
    content {
      key                 = ""
      propagate_at_launch = false
      value               = ""
    }
  }
}