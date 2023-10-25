locals {
  container_definition_prometheus = {
    name  = "prometheus"
    image = "prom/prometheus"

    essential          = true
    memory             = 1500
    links              = ["ecs-discover"]
    execution_role_arn = aws_iam_role.get_secrets.arn

    portMappings = [
      {
        containerPort = 9090
        hostPort      = 0
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
        sourceVolume  = "prometheus_data"
        containerPath = "/data"
      },
      {
        sourceVolume  = "prometheus_config"
        containerPath = "/prometheus"
      }
    ]
    command = concat([
      "--web.enable-lifecycle",
      "--storage.tsdb.path=/data",
      "--config.file=/prometheus/prometheus.yml",
      "--storage.tsdb.retention.size=3GB",
    ])
    logConfiguration = {
      logDriver = "awslogs"
      options   = {
        awslogs-group         = aws_cloudwatch_log_group.for_prometheus.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "promethues"
      }
    }
  }
}