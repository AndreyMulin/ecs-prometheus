locals {
  container_definition_cloudwatch = {
    name  = "cloudwatch"
    image = "prom/cloudwatch-exporter:v0.15.3"

    essential          = true
    memory             = 256
    links              = ["prometheus"]

    portMappings = [
      {
        containerPort = 9106
        hostPort      = 9106
        protocol      = "tcp"
      }
    ]
    dependsOn = [
      {
        containerName = "sync-config"
        condition     = "HEALTHY"
      }
    ]
    mountPoints = [
      {
        sourceVolume  = "prometheus_config"
        containerPath = "/prometheus"
      }
    ]
    entryPoint = concat([
      "java",
      "-jar",
      "/cloudwatch_exporter.jar",
      "9106",
      "/prometheus/cloudwatch.yml",
    ])
    dockerLabels = {
      PROMETHEUS_SCRAPES = "9106"
    }
    logConfiguration = {
      logDriver = "awslogs"
      options   = {
        awslogs-group         = aws_cloudwatch_log_group.for_prometheus.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "cloudwatch"
      }
    }
  }
}