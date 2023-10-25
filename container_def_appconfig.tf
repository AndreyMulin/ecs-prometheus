locals {
  sync_config_env_list = {
    AWS_REGION                           = var.aws_region
    PROMETHEUS_EXTERNAL_LABEL_PROMETHEUS = "it-aws-1"
    PROMETHEUS_EXTERNAL_LABEL_TEAM       = "it-monitoring"
    PROMETHEUS_EXTERNAL_LABEL_SERVICE    = "test"

    PROMETHEUS_SERVICE_THANOS_USERNAME = "thanos_user"
    PROMETHEUS_SERVICE_ALERT_MANAGER_USERNAME = "alert_manager_user"
  }
}

locals {
  container_definition_sync_config = {
    name  = "sync-config"
    image = "public.ecr.aws/c8i0g6a2/sync-config:21"

    essential = true
    memory    = 100
    dependsOn = [
      {
        containerName = "init"
        condition     = "COMPLETE"
      }
    ]
    command = [
      "--aws-app-config-app-name=${aws_appconfig_application.prometheus.name}",
      "--aws-app-config-env-name=${aws_appconfig_environment.prometheus.name}",
      "--aws-app-config-conf-profile=${aws_appconfig_configuration_profile.sc-config.name}",
      "--config-reload-url=http://${aws_lb.prom.dns_name}:9090/-/reload",
      "--config-directory=/sync-config/config",
      "--checkInterval=60"
    ]
    healthCheck = {
      command     = ["CMD-SHELL", "test -f /sync-config/config/prometheus.yml && test -f /sync-config/config/cloudwatch.yml || exit 1"]
      interval    = 5
      retries     = 3
      startPeriod = 5
      timeout     = 5
    }
    environment = [
      for name, value in local.sync_config_env_list : {
        name  = name
        value = tostring(value)
      }
    ]
    secrets = [
      for each in [
        {
          name      = "PROMETHEUS_SERVICE_THANOS_PASSWORD"
          valueFrom = aws_ssm_parameter.thanos_password.arn
        },
        {
          name      = "PROMETHEUS_SERVICE_ALERT_MANAGER_PASSWORD"
          valueFrom = aws_ssm_parameter.alertmanager_password.arn
        },
      ] : each if each.valueFrom != ""
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options   = {
        awslogs-group         = aws_cloudwatch_log_group.for_prometheus.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "appconfig"
      }
    }
    mountPoints = [
      {
        sourceVolume  = "prometheus_config"
        containerPath = "/sync-config/config"
      }
    ]
  }
}


