run "setup_tests" {
  module {
    source = "./tests/setup"
  }
}

run "fargate_cluster" {
  command = [plan,apply]

  variables {
    cluster = [
      {
        id    = 0
        name  = "white-hart"
        setting = [
          {
            name  = "containerInsights"
            value = "enabled"
          }
        ]
      }
    ]
    cluster_capacity_providers = [
      {
        id                  = 0
        cluster_id          = 0
        capacity_providers  = ["FARGATE"]
        default_capacity_provider_strategy = [
          {
            base              = 1
            weight            = 100
            capacity_provider = "FARGATE"
          }
        ]
      }
    ]
    task_definition = [
      {
        id                    = 0
        family                = "service"
        container_definitions = file("task-definitions/service.json")
        proxy_configuration = [
          {
            type           = "APPMESH"
            container_name = "applicationContainerName"
            properties = {
              AppPorts         = "8080"
              EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
              IgnoredUID       = "1337"
              ProxyEgressPort  = 15001
              ProxyIngressPort = 15000
            }
          }
        ]
      }
    ]
    service = [
      {
        id                  = 0
        name                = "mongodb"
        cluster_id          = 0
        task_definition_id  = 0
        desired_count       = 3
      }
    ]
  }
}