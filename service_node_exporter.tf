resource "aws_ecs_task_definition" "task_definition_node_exporter" {
  family                = "node_exporter"
  container_definitions = jsonencode(flatten([
    local.container_definition_node_exporter,
  ]))
  volume {
    name      = "node-proc"
    host_path = "/proc"
  }
  volume {
    name      = "node-rootfs"
    host_path = "/"
  }
  volume {
    name      = "node-sys"
    host_path = "/sys"
  }
}

resource "aws_ecs_service" "node_exporter" {
  name                = "node_exporter"
  cluster             = aws_ecs_cluster.for_prometheus.id
  task_definition     = aws_ecs_task_definition.task_definition_node_exporter.arn
  desired_count       = 1
  scheduling_strategy = "DAEMON"

  load_balancer {
    target_group_arn = aws_alb_target_group.node_exporter.arn
    container_name   = "node-exporter"
    container_port   = 9100
  }
}