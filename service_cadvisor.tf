resource "aws_ecs_task_definition" "task_cadvisor" {
  family             = "cadvisor"
  container_definitions = jsonencode(flatten([
    local.container_definition_cadvisor,
  ]))
  volume {
    name      = "cadvisor-rootfs"
    host_path = "/"
  }
  volume {
    name      = "cadvisor-run"
    host_path = "/var/run"
  }
  volume {
    name      = "cadvisor-sys"
    host_path = "/sys"
  }
  volume {
    name      = "cadvisor-docker"
    host_path = "/var/lib/docker"
  }
  volume {
    name      = "cadvisor-disk"
    host_path = "/dev/disk"
  }
}

resource "aws_ecs_service" "cadvisor" {
  name                               = "cadvisor"
  cluster                            = aws_ecs_cluster.for_prometheus.id
  task_definition                    = aws_ecs_task_definition.task_cadvisor.arn
  scheduling_strategy                = "DAEMON"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  depends_on                         = [aws_iam_role.ecs_agent]

  load_balancer {
    target_group_arn = aws_alb_target_group.cadvisor.arn
    container_name   = "cadvisor"
    container_port   = 8080
  }
}