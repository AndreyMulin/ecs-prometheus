resource "aws_ecs_task_definition" "task_definition_prometheus" {
  family                = "prometheus"
  execution_role_arn    = aws_iam_role.get_secrets.arn
  task_role_arn         = aws_iam_role.ecs_prometheus.arn
  container_definitions = jsonencode(flatten([
    local.container_definition_init,
    local.container_definition_prometheus,
    local.container_definition_sync_config,
    local.container_definition_ecs_discover,
    local.container_definition_cloudwatch,
  ]))
  volume {
    name      = "prometheus_config"
    host_path = "/data/prometheus"
  }
  volume {
    name      = "prometheus_data"
    host_path = "/data/promdata"
  }
}

resource "aws_ecs_service" "prometheus" {
  name            = "prometheus"
  cluster         = aws_ecs_cluster.for_prometheus.id
  task_definition = aws_ecs_task_definition.task_definition_prometheus.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_alb_target_group.prom.arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.cloudwatch.arn
    container_name   = "cloudwatch"
    container_port   = 9106
  }

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "for_prometheus"
    weight            = 100
  }
}
