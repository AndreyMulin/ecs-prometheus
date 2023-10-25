locals {
  files_prometheus_config = [
    for file in tolist(fileset("prometheus", "*")) : {
      app-profile   = file
      filename      = file
      reloadService = file == "prometheus.yml" ? true : false
      validate      = file == "prometheus.yml" ? "promtool" : ""
    }
  ]
  files_prometheus_rules = [
    for file in tolist(fileset("prometheus/rules", "*")) : {
      app-profile   = "rules/${file}"
      filename      = "rules/${file}"
      reloadService = true
    }
  ]
  files_rules_common = [
    for file in tolist(fileset("prometheus/rules-common/rules", "*")) : {
      app-profile   = "rules-common/rules/${file}"
      filename      = "rules-common/rules/${file}"
      reloadService = true
      justCopy      = true
    }
  ]
  files_json = {
    files = concat(local.files_prometheus_config, local.files_prometheus_rules, local.files_rules_common)
  }
}
