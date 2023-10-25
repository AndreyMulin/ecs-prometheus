resource "aws_ssm_parameter" "thanos_password" {
  name        = "/prometheus/thanos_password"
  description = "Thanos Password"
  type        = "SecureString"
  value       = " "

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "alertmanager_password" {
  name        = "/prometheus/alertmanager_password"
  description = "AlertManager Password"
  type        = "SecureString"
  value       = " "

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}