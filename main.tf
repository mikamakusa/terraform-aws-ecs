resource "aws_ecs_account_setting_default" "this" {
  count = length(var.account_setting_default)
  name  = lookup(var.account_setting_default[count.index], "name")
  value = lookup(var.account_setting_default[count.index], "value")
}

resource "aws_ecs_capacity_provider" "this" {
  count = length(var.capacity_provider)
  name  = lookup(var.capacity_provider[count.index], "name")
  tags = merge(
    var.tags,
    lookup(var.capacity_provider[count.index], tags),
    data.aws_default_tags.this.tags
  )

  dynamic "auto_scaling_group_provider" {
    for_each = lookup(var.capacity_provider[count.index], "auto_scaling_group_provider")
    content {
      auto_scaling_group_arn         = data.aws_autoscaling_group.this.arn
      managed_termination_protection = lookup(auto_scaling_group_provider.value, "managed_termination_protection")
      managed_draining               = lookup(auto_scaling_group_provider.value, "managed_draining")

      dynamic "managed_scaling" {
        for_each = lookup(auto_scaling_group_provider.value, "managed_scaling") == null ? [] : ["managed_scaling"]
        content {
          instance_warmup_period    = lookup(managed_scaling.value, "instance_warmup_period")
          maximum_scaling_step_size = lookup(managed_scaling.value, "maximum_scaling_step_size")
          minimum_scaling_step_size = lookup(managed_scaling.value, "minimum_scaling_step_size")
          status                    = lookup(managed_scaling.value, "status")
          target_capacity           = lookup(managed_scaling.value, "target_capacity")
        }
      }
    }
  }
}

resource "aws_ecs_cluster" "this" {
  count = length(var.cluster)
  name  = lookup(var.cluster[count.index], "name")
  tags = merge(
    var.tags,
    lookup(var.cluster[count.index], tags),
    data.aws_default_tags.this.tags
  )

  dynamic "configuration" {
    for_each = try(lookup(var.cluster[count.index], "configuration") == null ? [] : ["configuration"])
    content {
      dynamic "execute_command_configuration" {
        for_each = lookup(configuration.value, "execute_command_configuration")
        content {
          kms_key_id = try(
            element(aws_kms_key.this.*.id, lookup(configuration.value, "kms_key_id"))
          )
          logging = lookup(execute_command_configuration.value, "logging")

          dynamic "log_configuration" {
            for_each = lookup(execute_command_configuration.value, "log_configuration") == null ? [] : ["log_configuration"]
            content {
              cloud_watch_encryption_enabled = lookup(log_configuration.value, "cloud_watch_encryption_enabled")
              cloud_watch_log_group_name     = lookup(log_configuration.value, "cloud_watch_log_group_name")
              s3_bucket_name                 = lookup(log_configuration.value, "s3_bucket_name")
              s3_key_prefix                  = lookup(log_configuration.value, "s3_key_prefix")
              s3_bucket_encryption_enabled   = lookup(log_configuration.value, "s3_bucket_encryption_enabled")
            }
          }
        }
      }
      dynamic "managed_storage_configuration" {
        for_each = lookup(configuration.value, "managed_storage_configuration") == null ? [] : ["managed_storage_configuration"]
        content {
          kms_key_id = try(
            element(aws_kms_key.this.*.id, lookup(managed_storage_configuration.value, "kms_key_id"))
          )
          fargate_ephemeral_storage_kms_key_id = try(
            element(aws_kms_key.this.*.id, lookup(managed_storage_configuration.value, "fargate_ephemeral_storage_kms_key_id"))
          )
        }
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = try(lookup(var.cluster[count.index], "service_connect_defaults") == null ? [] : ["service_connect_defaults"])
    content {
      namespace = lookup(service_connect_defaults.value, "namespace")
    }
  }

  dynamic "setting" {
    for_each = try(lookup(var.cluster[count.index], "setting") == null ? [] : ["setting"])
    content {
      name  = lookup(setting.value, "name")
      value = lookup(setting.value, "value")
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = length(var.cluster) == 0 ? 0 : length(var.cluster_capacity_providers)
  cluster_name = try(
    element(aws_ecs_cluster.this.*.name, lookup(var.cluster_capacity_providers[count.index], "cluster_id"))
  )
  capacity_providers = lookup(var.cluster_capacity_providers[count.index], "capacity_providers")

  dynamic "default_capacity_provider_strategy" {
    for_each = try(lookup(var.cluster_capacity_providers[count.index], "default_capacity_provider_strategy") == null ? [] : ["default_capacity_provider_strategy"])
    content {
      capacity_provider = lookup(default_capacity_provider_strategy.value, "capacity_provider")
      weight            = lookup(default_capacity_provider_strategy.value, "weight")
      base              = lookup(default_capacity_provider_strategy.value, "base")
    }
  }
}

resource "aws_ecs_service" "this" {
  count = length(var.cluster) == 0 ? 0 : length(var.service)
  name  = lookup(var.service[count.index], "name")
  cluster = try(
    element(aws_ecs_cluster.this.*.id, lookup(var.service[count.index], "cluster_id"))
  )
  deployment_maximum_percent         = lookup(var.service[count.index], "deployment_maximum_percent")
  deployment_minimum_healthy_percent = lookup(var.service[count.index], "deployment_minimum_healthy_percent")
  desired_count                      = lookup(var.service[count.index], "desired_count")
  enable_ecs_managed_tags            = lookup(var.service[count.index], "enable_ecs_managed_tags")
  enable_execute_command             = lookup(var.service[count.index], "enable_execute_command")
  force_new_deployment               = lookup(var.service[count.index], "force_new_deployment")
  health_check_grace_period_seconds  = lookup(var.service[count.index], "health_check_grace_period_seconds")
  iam_role                           = var.ecs_service_role_arn
  launch_type                        = lookup(var.service[count.index], "launch_type")
  platform_version                   = lookup(var.service[count.index], "platform_version")
  propagate_tags                     = lookup(var.service[count.index], "propagate_tags")
  scheduling_strategy                = lookup(var.service[count.index], "scheduling_strategy")
  tags = merge(
    var.tags,
    lookup(var.service[count.index], tags),
    data.aws_default_tags.this.tags
  )
  task_definition = try(
    element(aws_ecs_task_definition.this.*.arn, lookup(var.service[count.index], "task_definition_id"))
  )
  triggers              = lookup(var.service[count.index], "triggers")
  wait_for_steady_state = lookup(var.service[count.index], "wait_for_steady_state")

  dynamic "alarms" {
    for_each = try(lookup(var.service[count.index], "alarms") == null ? [] : ["alarms"])
    content {
      rollback    = lookup(alarms.value, "rollback")
      alarm_names = lookup(alarms.value, "alarm_names")
      enable      = lookup(alarms.value, "enable")
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = try(lookup(var.service[count.index], "capacity_provider_strategy") == null ? [] : ["capacity_provider_strategy"])
    content {
      capacity_provider = lookup(capacity_provider_strategy.value, "capacity_provider")
      base              = lookup(capacity_provider_strategy.value, "base")
      weight            = lookup(capacity_provider_strategy.value, "weight")
    }
  }

  dynamic "deployment_circuit_breaker" {
    for_each = try(lookup(var.service[count.index], "deployment_circuit_breaker") == null ? [] : ["deployment_circuit_breaker"])
    content {
      rollback = lookup(deployment_circuit_breaker.value, "rollback")
      enable   = lookup(deployment_circuit_breaker.value, "enable")
    }
  }

  dynamic "deployment_controller" {
    for_each = try(lookup(var.service[count.index], "deployment_controller") == null ? [] : ["deployment_controller"])
    content {
      type = lookup(deployment_controller.value, "type")
    }
  }

  dynamic "load_balancer" {
    for_each = try(lookup(var.service[count.index], "load_balancer") == null ? [] : ["load_balancer"])
    content {
      container_name   = lookup(load_balancer.value, "container_name")
      container_port   = lookup(load_balancer.value, "container_port")
      elb_name         = data.aws_lb.this.arn
      target_group_arn = data.aws_lb_target_group.this.arn
    }
  }

  dynamic "network_configuration" {
    for_each = try(lookup(var.service[count.index], "network_configuration") == null ? [] : ["network_configuration"])
    content {
      subnets = [try(
        element(aws_subnet.this.*.id, lookup(network_configuration.value, "subnet_id"))
      )]
      security_groups = [try(
        element(aws_security_group.this.*.id, lookup(network_configuration.value, "security_group_id"))
      )]
      assign_public_ip = lookup(network_configuration.value, "assign_public_ip")
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = try(lookup(var.service[count.index], "ordered_placement_strategy") == null ? [] : ["ordered_placement_strategy"])
    content {
      type  = lookup(ordered_placement_strategy.value, "type")
      field = lookup(ordered_placement_strategy.value, "field")
    }
  }

  dynamic "placement_constraints" {
    for_each = try(lookup(var.service[count.index], "placement_constraints") == null ? [] : ["placement_constraints"])
    content {
      type       = lookup(placement_constraints.value, "type")
      expression = lookup(placement_constraints.value, "expression")
    }
  }

  dynamic "service_connect_configuration" {
    for_each = try(lookup(var.service[count.index], "service_connect_configuration") == null ? [] : ["service_connect_configuration"])
    content {
      enabled   = lookup(service_connect_configuration.value, "enabled")
      namespace = lookup(service_connect_configuration.value, "namespace")

      dynamic "log_configuration" {
        for_each = lookup(service_connect_configuration.value, "log_configuration") == null ? [] : ["log_configuration"]
        content {
          log_driver = lookup(log_configuration.value, "log_driver")
          options    = lookup(log_configuration.value, "options")

          dynamic "secret_option" {
            for_each = lookup(log_configuration.value, "secret_option") == null ? [] : ["secret_option"]
            content {
              value_from = lookup(secret_option.value, "value_from")
              name       = lookup(secret_option.value, "name")
            }
          }
        }
      }

      dynamic "service" {
        for_each = lookup(service_connect_configuration.value, "service") == null ? [] : ["service"]
        content {
          port_name             = lookup(service.value, "port_name")
          discovery_name        = lookup(service.value, "discovery_name")
          ingress_port_override = lookup(service.value, "ingress_port_override")

          dynamic "client_alias" {
            for_each = lookup(service.value, "client_alias") == null ? [] : ["client_alias"]
            content {
              port     = lookup(client_alias.value, "port")
              dns_name = lookup(client_alias.value, "dns_name")
            }
          }

          dynamic "timeout" {
            for_each = lookup(service.value, "timeout") == null ? [] : ["timeout"]
            content {
              idle_timeout_seconds        = lookup(timeout.value, "idle_timeout_seconds")
              per_request_timeout_seconds = lookup(timeout.value, "per_request_timeout_seconds")
            }
          }

          dynamic "tls" {
            for_each = lookup(service.value, "tls") == null ? [] : ["tls"]
            content {
              kms_key = try(
                element(aws_kms_key.this.*.id, lookup(tls.value, "kms_key_id"))
              )
              role_arn = var.ecs_service_tls_role

              dynamic "issuer_cert_authority" {
                for_each = lookup(tls.value, "issuer_cert_authority")
                content {
                  aws_pca_authority_arn = data.aws_acmpca_certificate_authority.this.arn
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "service_registries" {
    for_each = try(lookup(var.service[count.index], "service_registries") == null ? [] : ["service_registries"])
    content {
      registry_arn   = data.aws_service_discovery_service.this.arn
      port           = lookup(service_registries.value, "port")
      container_port = lookup(service_registries.value, "container_port")
      container_name = lookup(service_registries.value, "container_name")
    }
  }

  dynamic "volume_configuration" {
    for_each = try(lookup(var.service[count.index], "volume_configuration") == null ? [] : ["volume_configuration"])
    content {
      name = lookup(volume_configuration.value, "name")

      dynamic "managed_ebs_volume" {
        for_each = lookup(volume_configuration.value, "managed_ebs_volume") == null ? [] : ["managed_ebs_volume"]
        content {
          role_arn         = var.ecs_service_managed_volume_role
          encrypted        = lookup(managed_ebs_volume.value, "encrypted")
          file_system_type = lookup(managed_ebs_volume.value, "file_system_type")
          iops             = lookup(managed_ebs_volume.value, "iops")
          kms_key_id = try(
            element(aws_kms_key.this.*.id, lookup(managed_ebs_volume.value, "kms_key_id"))
          )
          size_in_gb  = lookup(managed_ebs_volume.value, "size_in_gb")
          snapshot_id = lookup(managed_ebs_volume.value, "snapshot_id")
          throughput  = lookup(managed_ebs_volume.value, "throughput")
          volume_type = lookup(managed_ebs_volume.value, "volume_type")
        }
      }
    }
  }
}

resource "aws_ecs_tag" "this" {
  count        = length(var.tag)
  key          = lookup(var.tag[count.index], "key")
  resource_arn = var.tag_resource_arn
  value        = lookup(var.tag[count.index], "value")
}

resource "aws_ecs_task_definition" "this" {
  count                    = length(var.task_definition)
  container_definitions    = join("/", [path.cwd, "definitions", file(lookup(var.task_definition[count.index], "container_definitions"))])
  family                   = lookup(var.task_definition[count.index], "family")
  cpu                      = lookup(var.task_definition[count.index], "cpu")
  execution_role_arn       = var.ecs_task_definition_execution_role
  ipc_mode                 = lookup(var.task_definition[count.index], "ipc_mode")
  memory                   = lookup(var.task_definition[count.index], "memory")
  network_mode             = lookup(var.task_definition[count.index], "network_mode")
  pid_mode                 = lookup(var.task_definition[count.index], "pid_mode")
  requires_compatibilities = lookup(var.task_definition[count.index], "requires_compatibilities")
  skip_destroy             = lookup(var.task_definition[count.index], "skip_destroy")
  tags = merge(
    var.tags,
    lookup(var.task_definition[count.index], tags),
    data.aws_default_tags.this.tags
  )
  task_role_arn = var.ecs_task_definition_task_role
  track_latest  = lookup(var.task_definition[count.index], "track_latest")

  dynamic "ephemeral_storage" {
    for_each = lookup(var.task_definition[count.index], "ephemeral_storage") == null ? [] : ["ephemeral_storage"]
    content {
      size_in_gib = lookup(ephemeral_storage.value, "size_in_gib")
    }
  }

  dynamic "inference_accelerator" {
    for_each = lookup(var.task_definition[count.index], "inference_accelerator") == null ? [] : ["inference_accelerator"]
    content {
      device_name = lookup(inference_accelerator.value, "device_name")
      device_type = lookup(inference_accelerator.value, "device_type")
    }
  }

  dynamic "placement_constraints" {
    for_each = lookup(var.task_definition[count.index], "placement_constraints") == null ? [] : ["placement_constraints"]
    content {
      type       = lookup(placement_constraints.value, "type")
      expression = lookup(placement_constraints.value, "expression")
    }
  }

  dynamic "proxy_configuration" {
    for_each = lookup(var.task_definition[count.index], "proxy_configuration") == null ? [] : ["proxy_configuration"]
    content {
      container_name = lookup(proxy_configuration.value, "container_name")
      properties     = lookup(proxy_configuration.value, "properties")
      type           = lookup(proxy_configuration.value, "type")
    }
  }

  dynamic "runtime_platform" {
    for_each = lookup(var.task_definition[count.index], "runtime_platform") == null ? [] : ["runtime_platform"]
    content {
      operating_system_family = lookup(runtime_platform.value, "operating_system_family")
      cpu_architecture        = lookup(runtime_platform.value, "cpu_architecture")
    }
  }

  dynamic "volume" {
    for_each = lookup(var.task_definition[count.index], "volume") == null ? [] : ["volume"]
    content {
      name                = lookup(volume.value, "name")
      host_path           = lookup(volume.value, "host_path")
      configure_at_launch = lookup(volume.value, "configure_at_launch")

      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration") == null ? [] : ["docker_volume_configuration"]
        content {
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision")
          driver        = lookup(docker_volume_configuration.value, "driver")
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts")
          labels        = lookup(docker_volume_configuration.value, "labels")
          scope         = lookup(docker_volume_configuration.value, "scope")
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration") == null ? [] : ["efs_volume_configuration"]
        content {
          file_system_id          = lookup(efs_volume_configuration.value, "file_system_id")
          root_directory          = lookup(efs_volume_configuration.value, "root_directory")
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption")
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port")

          dynamic "authorization_config" {
            for_each = lookup(efs_volume_configuration.value, "authorization_config")
            content {
              access_point_id = lookup(authorization_config.value, "access_point_id")
              iam             = lookup(authorization_config.value, "iam")
            }
          }
        }
      }

      dynamic "fsx_windows_file_server_volume_configuration" {
        for_each = lookup(volume.value, "fsx_windows_file_server_volume_configuration") == null ? [] : ["fsx_windows_file_server_volume_configuration"]
        content {
          root_directory = lookup(fsx_windows_file_server_volume_configuration.value, "root_directory")
          file_system_id = lookup(fsx_windows_file_server_volume_configuration.value, "file_system_id")

          dynamic "authorization_config" {
            for_each = lookup(fsx_windows_file_server_volume_configuration.value, "authorization_config")
            content {
              domain                = lookup(authorization_config.value, "domain")
              credentials_parameter = lookup(authorization_config.value, "credentials_parameter")
            }
          }
        }
      }
    }
  }
}

resource "aws_ecs_task_set" "this" {
  count = (length(var.cluster) && length(var.service) && length(var.task_definition)) == 0 ? 0 : length(var.task_set)
  cluster = try(
    element(aws_ecs_cluster.this.*.id, lookup(var.task_set[count.index], "cluster_id"))
  )
  service = try(
    element(aws_ecs_service.this.*.id, lookup(var.task_set[count.index], "service_id"))
  )
  task_definition = try(
    element(aws_ecs_task_definition.this.*.arn, lookup(var.task_set[count.index], "task_definition_id"))
  )
  external_id      = lookup(var.task_set[count.index], "external_id")
  force_delete     = lookup(var.task_set[count.index], "force_delete")
  launch_type      = lookup(var.task_set[count.index], "launch_type")
  platform_version = lookup(var.task_set[count.index], "platform_version")
  tags = merge(
    var.tags,
    lookup(var.task_set[count.index], tags),
    data.aws_default_tags.this.tags
  )
  wait_until_stable         = lookup(var.task_set[count.index], "wait_until_stable")
  wait_until_stable_timeout = lookup(var.task_set[count.index], "wait_until_stable_timeout")

  dynamic "capacity_provider_strategy" {
    for_each = lookup(var.task_set[count.index], "capacity_provider_strategy") == null ? [] : ["capacity_provider_strategy"]
    content {
      capacity_provider = lookup(capacity_provider_strategy.value, "capacity_provider")
      weight            = lookup(capacity_provider_strategy.value, "weight")
      base              = lookup(capacity_provider_strategy.value, "base")
    }
  }

  dynamic "load_balancer" {
    for_each = lookup(var.task_set[count.index], "load_balancer") == null ? [] : ["load_balancer"]
    content {
      container_name     = lookup(load_balancer.value, "container_name")
      container_port     = lookup(load_balancer.value, "container_port")
      load_balancer_name = data.aws_lb.this.arn
      target_group_arn   = data.aws_lb_target_group.this.arn
    }
  }

  dynamic "network_configuration" {
    for_each = lookup(var.task_set[count.index], "network_configuration") == null ? [] : ["network_configuration"]
    content {
      subnets = [
        try(
          element(aws_subnet.this.*.id, lookup(network_configuration.value, "subnet_id"))
        )
      ]
      security_groups = [
        try(
          element(aws_security_group.this.*.id, lookup(network_configuration.value, "security_group_id"))
        )
      ]
      assign_public_ip = lookup(network_configuration.value, "assign_public_ip")
    }
  }

  dynamic "scale" {
    for_each = lookup(var.task_set[count.index], "scale") == null ? [] : ["scale"]
    content {
      unit  = lookup(scale.value, "unit")
      value = lookup(scale.value, "value")
    }
  }

  dynamic "service_registries" {
    for_each = lookup(var.task_set[count.index], "service_registries") == null ? [] : ["service_registries"]
    content {
      registry_arn   = data.aws_service_discovery_service.this.arn
      port           = lookup(service_registries.value, "port")
      container_name = lookup(service_registries.value, "container_name")
      container_port = lookup(service_registries.value, "container_port")
    }
  }
}