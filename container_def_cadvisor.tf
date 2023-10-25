locals {
  container_definition_cadvisor = {
    name  = "cadvisor"
    image = "gcr.io/cadvisor/cadvisor:v0.47.0"

    essential    = true
    memory       = 128
    portMappings = [
      {
        containerPort = 8080
        hostPort      = 9101
        protocol      = "tcp"
      }
    ]
    command = [
      "-docker_only",
      "-disable_metrics=tcp,udp,sched,process,percpu",
      "-event_storage_age_limit=default=1m",
      "-housekeeping_interval=15s",
      "-global_housekeeping_interval=1m",
      "-storage_duration=1m",
      "-store_container_labels=false",
      "-disable_root_cgroup_stats"
    ]
    mountPoints = [
      {
        sourceVolume  = "cadvisor-rootfs",
        containerPath = "/rootfs",
        readOnly      = true
      },
      {
        sourceVolume  = "cadvisor-run",
        containerPath = "/var/run",
        readOnly      = false
      },
      {
        sourceVolume  = "cadvisor-sys",
        containerPath = "/sys",
        readOnly      = true
      },
      {
        sourceVolume  = "cadvisor-docker",
        containerPath = "/var/lib/docker",
        readOnly      = true
      },
      {
        sourceVolume  = "cadvisor-disk",
        containerPath = "/dev/disk",
        readOnly      = true
      }
    ]
    dockerLabels = {
      PROMETHEUS_SCRAPES = "9101"
    }
    logConfiguration = {
      logDriver = "awslogs"
      options   = {
        awslogs-group         = aws_cloudwatch_log_group.for_prometheus.name
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "init"
      }
    }
  }
}
