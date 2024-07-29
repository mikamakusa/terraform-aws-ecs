variable "autoscaling_group_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "lb_target_group_name" {
  type    = string
  default = null
}

variable "aws_lb" {
  type    = string
  default = null
}

variable "aws_service_discovery_service_name" {
  type    = string
  default = null
}

variable "aws_service_discovery_service_namespace" {
  type    = string
  default = null
}

variable "tag_resource_arn" {
  type    = any
  default = null
}

variable "account_setting_default" {
  type = list(object({
    id    = number
    name  = string
    value = string
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "ecs_service_role_arn" {
  type    = string
  default = null
}

variable "ecs_service_tls_role" {
  type    = string
  default = null
}

variable "ecs_service_managed_volume_role" {
  type    = string
  default = null
}

variable "ecs_task_definition_execution_role" {
  type    = string
  default = null
}

variable "ecs_task_definition_task_role" {
  type    = string
  default = null
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "aws_acmpca_certificate_authority_arn" {
  type    = string
  default = null
}

variable "capacity_provider" {
  type = list(object({
    id   = number
    name = string
    tags = optional(map(string))
    auto_scaling_group_provider = list(object({
      auto_scaling_group_arn         = string
      managed_termination_protection = optional(string)
      managed_draining               = optional(string)
      managed_scaling = optional(list(object({
        instance_warmup_period    = optional(number)
        maximum_scaling_step_size = optional(number)
        minimum_scaling_step_size = optional(number)
        status                    = optional(string)
        target_capacity           = optional(string)
      })), [])
    }))
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "cluster" {
  type = list(object({
    id   = number
    name = string
    tags = optional(map(string))
    configuration = optional(list(object({
      execute_command_configuration = optional(list(object({
        kms_key_id = optional(any)
        logging    = optional(string)
        log_configuration = optional(list(object({
          cloud_watch_encryption_enabled = optional(bool)
          cloud_watch_log_group_name     = optional(string)
          s3_bucket_name                 = optional(string)
          s3_key_prefix                  = optional(string)
          s3_bucket_encryption_enabled   = optional(bool)
        })), [])
      })), [])
      managed_storage_configuration = optional(list(object({
        kms_key_id                           = optional(any)
        fargate_ephemeral_storage_kms_key_id = optional(any)
      })), [])
    })), [])
    service_connect_defaults = optional(list(object({
      namespace = string
    })), [])
    setting = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "cluster_capacity_providers" {
  type = list(object({
    id                 = number
    cluster_id         = any
    capacity_providers = optional(any)
    default_capacity_provider_strategy = optional(list(object({
      capacity_provider = any
      weight            = optional(number)
      base              = optional(number)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "service" {
  type = list(object({
    id                                 = number
    name                               = string
    cluster                            = optional(any)
    deployment_maximum_percent         = optional(number)
    deployment_minimum_healthy_percent = optional(number)
    desired_count                      = optional(number)
    enable_ecs_managed_tags            = optional(bool)
    enable_execute_command             = optional(bool)
    force_new_deployment               = optional(bool)
    health_check_grace_period_seconds  = optional(number)
    iam_role                           = optional(string)
    launch_type                        = optional(string)
    platform_version                   = optional(string)
    propagate_tags                     = optional(string)
    scheduling_strategy                = optional(string)
    tags                               = optional(map(string))
    task_definition_id                 = optional(any)
    triggers                           = optional(map(string))
    wait_for_steady_state              = optional(bool)
    alarms = optional(list(object({
      rollback    = bool
      alarm_names = list(string)
      enable      = bool
    })), [])
    capacity_provider_strategy = optional(list(object({
      capacity_provider = string
      base              = optional(number)
      weight            = optional(number)
    })), [])
    deployment_circuit_breaker = optional(list(object({
      rollback = bool
      enable   = bool
    })), [])
    deployment_controller = optional(list(object({
      type = optional(string)
    })), [])
    load_balancer = optional(list(object({
      container_name   = string
      container_port   = number
      elb_name         = optional(any)
      target_group_arn = optional(any)
    })), [])
    network_configuration = optional(list(object({
      subnets          = any
      security_groups  = optional(any)
      assign_public_ip = optional(bool)
    })), [])
    ordered_placement_strategy = optional(list(object({
      type  = string
      field = optional(string)
    })), [])
    placement_constraints = optional(list(object({
      type       = string
      expression = optional(string)
    })), [])
    service_connect_configuration = optional(list(object({
      enabled   = bool
      namespace = optional(string)
      log_configuration = optional(list(object({
        log_driver = string
        options    = optional(map(string))
        secret_option = optional(list(object({
          value_from = string
          name       = string
        })), [])
      })), [])
      service = optional(list(object({
        port_name             = optional(string)
        discovery_name        = optional(string)
        ingress_port_override = optional(number)
        client_alias = optional(list(object({
          port     = number
          dns_name = optional(string)
        })), [])
        timeout = optional(list(object({
          idle_timeout_seconds        = optional(number)
          per_request_timeout_seconds = optional(number)
        })), [])
        tls = optional(list(object({
          kms_key  = optional(any)
          role_arn = optional(string)
          issuer_cert_authority = list(object({
            aws_pca_authority_arn = optional(string)
          }))
        })), [])
      })), [])
    })), [])
    service_registries = optional(list(object({
      registry_arn   = any
      port           = optional(number)
      container_port = optional(number)
      container_name = optional(string)
    })), [])
    volume_configuration = optional(list(object({
      name = string
      managed_ebs_volume = list(object({
        role_arn         = any
        encrypted        = optional(bool)
        file_system_type = optional(string)
        iops             = optional(number)
        kms_key_id       = optional(any)
        size_in_gb       = optional(number)
        snapshot_id      = optional(string)
        throughput       = optional(number)
        volume_type      = optional(string)
      }))
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "tag" {
  type = list(object({
    id    = number
    key   = string
    value = string
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "task_definition" {
  type = list(object({
    id                       = number
    container_definitions    = string
    family                   = optional(string)
    cpu                      = optional(string)
    execution_role_arn       = optional(string)
    ipc_mode                 = optional(string)
    memory                   = optional(string)
    network_mode             = optional(string)
    pid_mode                 = optional(string)
    requires_compatibilities = optional(list(string))
    skip_destroy             = optional(bool)
    tags                     = optional(map(string))
    task_role_arn            = optional(string)
    track_latest             = optional(bool)
    ephemeral_storage = optional(list(object({
      size_in_gib = number
    })), [])
    inference_accelerator = optional(list(object({
      device_name = string
      device_type = string
    })), [])
    placement_constraints = optional(list(object({
      type       = string
      expression = optional(string)
    })), [])
    proxy_configuration = optional(list(object({
      container_name = string
      properties     = map(string)
      type           = optional(string)
    })), [])
    runtime_platform = optional(list(object({
      operating_system_family = optional(string)
      cpu_architecture        = optional(string)
    })), [])
    volume = optional(list(object({
      name                = string
      host_path           = optional(string)
      configure_at_launch = optional(bool)
      docker_volume_configuration = optional(list(object({
        autoprovision = optional(bool)
        driver        = optional(string)
        driver_opts   = optional(map(string))
        labels        = optional(map(string))
        scope         = optional(string)
      })), [])
      efs_volume_configuration = optional(list(object({
        file_system_id          = string
        root_directory          = optional(string)
        transit_encryption      = optional(string)
        transit_encryption_port = optional(number)
        authorization_config = optional(list(object({
          access_point_id = optional(string)
          iam             = optional(string)
        })), [])
      })), [])
      fsx_windows_file_server_volume_configuration = optional(list(object({
        root_directory = string
        file_system_id = string
        authorization_config = list(object({
          domain                = string
          credentials_parameter = string
        }))
      })), [])
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "task_set" {
  type = list(object({
    id                        = number
    cluster_id                = any
    service_id                = any
    task_definition_id        = any
    external_id               = optional(string)
    force_delete              = optional(bool)
    launch_type               = optional(string)
    platform_version          = optional(string)
    tags                      = optional(map(string))
    wait_until_stable         = optional(bool)
    wait_until_stable_timeout = optional(string)
    capacity_provider_strategy = optional(list(object({
      capacity_provider = string
      weight            = number
      base              = optional(number)
    })), [])
    load_balancer = optional(list(object({
      container_name     = string
      container_port     = optional(string)
      load_balancer_name = optional(any)
      target_group_arn   = optional(any)
    })), [])
    network_configuration = optional(list(object({
      subnets          = list(any)
      security_groups  = optional(list(any))
      assign_public_ip = optional(bool)
    })), [])
    scale = optional(list(object({
      unit  = optional(string)
      value = optional(number)
    })), [])
    service_registries = optional(list(object({
      registry_arn   = any
      port           = optional(number)
      container_name = optional(string)
      container_port = optional(number)
    })), [])
  }))
  default     = []
  description = <<EOF
    EOF
}

variable "kms_key" {
  type = list(object({
    id                                 = number
    customer_master_key_spec           = optional(string)
    deletion_window_in_days            = optional(number)
    description                        = optional(string)
    enable_key_rotation                = optional(bool)
    is_enabled                         = optional(bool)
    key_usage                          = optional(string)
    policy                             = optional(strng)
    tags                               = optional(map(string))
    bypass_policy_lockout_safety_check = optional(bool)
    custom_key_store_id                = optional(string)
    multi_region                       = optional(bool)
    rotation_period_in_days            = optional(number)
    xks_key_id                         = optional(string)
  }))
  default = []
}

variable "kms_key_policy" {
  type = list(object({
    id                                 = number
    key_id                             = any
    policy                             = string
    bypass_policy_lockout_safety_check = optional(bool)
  }))
  default = []
}

variable "lb" {
  type = list(object({
    id                               = number
    customer_owned_ipv4_pool         = optional(string)
    desync_mitigation_mode           = optional(string)
    drop_invalid_header_fields       = optional(bool)
    enable_cross_zone_load_balancing = optional(bool)
    enable_deletion_protection       = optional(bool)
    enable_http2                     = optional(bool)
    enable_waf_fail_open             = optional(bool)
    idle_timeout                     = optional(number)
    internal                         = optional(bool)
    ip_address_type                  = optional(string)
    load_balancer_type               = optional(string)
    name                             = optional(string)
    name_prefix                      = optional(string)
    preserve_host_header             = optional(bool)
    security_groups                  = optional(list(string))
    subnets                          = optional(list(string))
    tags                             = optional(map(string))
    access_logs = optional(list(object({
      bucket  = optional(any)
      enabled = optional(bool)
      prefix  = optional(string)
    })), [])
    subnet_mapping = optional(list(object({
      subnet_id            = optional(any)
      allocation_id        = optional(string)
      ipv6_address         = optional(string)
      private_ipv4_address = optional(string)
    })), [])
  }))
  default = []
}

variable "lb_target_group" {
  type = list(object({
    id                                 = number
    connection_termination             = optional(string)
    deregistration_delay               = optional(string)
    ip_address_type                    = optional(string)
    lambda_multi_value_headers_enabled = optional(bool)
    load_balancing_algorithm_type      = optional(string)
    name                               = optional(string)
    name_prefix                        = optional(string)
    port                               = optional(number)
    preserve_client_ip                 = optional(string)
    protocol                           = optional(string)
    protocol_version                   = optional(string)
    proxy_protocol_v2                  = optional(bool)
    slow_start                         = optional(bool)
    tags                               = optional(map(string))
    target_type                        = optional(string)
    vpc_id                             = optional(string)
    health_check = optional(list(object({
      enabled             = optional(bool)
      healthy_threshold   = optional(number)
      interval            = optional(number)
      matcher             = optional(string)
      path                = optional(string)
      port                = optional(string)
      protocol            = optional(string)
      timeout             = optional(number)
      unhealthy_threshold = optional(number)
    })), [])
    stickiness = optional(list(object({
      type            = optional(string)
      cookie_duration = optional(number)
      cookie_name     = optional(string)
      enabled         = optional(bool)
    })), [])
  }))
}