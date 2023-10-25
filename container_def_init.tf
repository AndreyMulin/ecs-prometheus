locals {
  container_definition_init = {
    name  = "init"
    image = "busybox"

    essential         = false
    memory            = 50
    command           = [
      "/bin/sh",
      "-c",
      "chown -R 65534:65534 /prometheus /data ; rm -rf /data/*"
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
    logConfiguration = {
      logDriver = "awslogs"
      options   = {
        awslogs-group         = aws_cloudwatch_log_group.for_prometheus.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "init"
      }
    }
  }
}
