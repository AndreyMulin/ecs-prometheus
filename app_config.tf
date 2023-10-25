resource "aws_appconfig_application" "prometheus" {
  name = "prometheus"
}

resource "aws_appconfig_environment" "prometheus" {
  name           = "prometheus-environment"
  application_id = aws_appconfig_application.prometheus.id
}

resource "aws_appconfig_deployment_strategy" "prometheus" {
  name                           = "prometheus-fast"
  description                    = "All at once"
  deployment_duration_in_minutes = 0
  final_bake_time_in_minutes     = 0
  growth_factor                  = 100
  growth_type                    = "LINEAR"
  replicate_to                   = "NONE"
}

# SC-config
resource "aws_appconfig_configuration_profile" "sc-config" {
  application_id = aws_appconfig_application.prometheus.id
  name           = "sc-config"
  location_uri   = "hosted"
}

resource "aws_appconfig_hosted_configuration_version" "sc-config" {
  application_id           = aws_appconfig_application.prometheus.id
  configuration_profile_id = aws_appconfig_configuration_profile.sc-config.configuration_profile_id
  content_type             = "application/x-yaml"

  content = jsonencode(local.files_json)
}

resource "aws_appconfig_deployment" "sc-config" {
  application_id           = aws_appconfig_application.prometheus.id
  configuration_profile_id = aws_appconfig_configuration_profile.sc-config.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.sc-config.version_number
  deployment_strategy_id   = aws_appconfig_deployment_strategy.prometheus.id
  description              = "Prometheus deployment"
  environment_id           = aws_appconfig_environment.prometheus.environment_id

  tags = {
    Type = "AppConfig Deployment"
  }
}

# Prometheus

resource "aws_appconfig_configuration_profile" "prometheus" {
  for_each       = { for file in local.files_json.files : file.filename => file }
  application_id = aws_appconfig_application.prometheus.id
  name           = each.value.app-profile
  location_uri   = "hosted"
}

resource "aws_appconfig_hosted_configuration_version" "prometheus" {
  for_each                 = { for file in local.files_json.files : file.filename => file }
  application_id           = aws_appconfig_application.prometheus.id
  configuration_profile_id = aws_appconfig_configuration_profile.prometheus[each.key].configuration_profile_id
  content_type             = "application/x-yaml"

  content = file("prometheus/${each.value.filename}")
}

resource "aws_appconfig_deployment" "prometheus" {
  for_each                 = { for file in local.files_json.files : file.filename => file }
  application_id           = aws_appconfig_application.prometheus.id
  configuration_profile_id = aws_appconfig_configuration_profile.prometheus[each.key].configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.prometheus[each.key].version_number
  deployment_strategy_id   = aws_appconfig_deployment_strategy.prometheus.id
  environment_id           = aws_appconfig_environment.prometheus.environment_id
}