locals {
  container_definition_ecs_discover = {
    name  = "ecs-discover"
    image = "public.ecr.aws/c8i0g6a2/ecs-sd:220206"

    essential = true
    memory    = 100
    user      = "65534:65534"
    dependsOn = [
      {
        containerName = "init"
        condition     = "COMPLETE"
      }
    ]

    command = [
      "-f=/prometheus/ecs_file_sd.yml",
      // "-l=debug", debug is possible options for this service
      "-c=${aws_ecs_cluster.for_prometheus.name}",
      "-i 60"
    ]
    environment = [
      {
        name  = "AWS_DEFAULT_REGION"
        value = var.aws_region
      }
    ]
    mountPoints = [
      {
        sourceVolume  = "prometheus_config"
        containerPath = "/prometheus"
        readOnly      = false
      }
    ]
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