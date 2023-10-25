resource "aws_ecs_cluster" "for_prometheus" {
  name = "for_prometheus"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.for_prometheus.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.for_prometheus.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "for_prometheus" {
  cluster_name = aws_ecs_cluster.for_prometheus.name
  capacity_providers = [aws_ecs_capacity_provider.for_prometheus.name]
}

resource "aws_ecs_capacity_provider" "for_prometheus" {
  name = "for_prometheus"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.prometheus_ecs_asg-priv.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 3
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

# Logs

resource "aws_kms_key" "for_prometheus" {
  description             = "for_prometheus"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "for_prometheus" {
  name = "for_prometheus"
}
