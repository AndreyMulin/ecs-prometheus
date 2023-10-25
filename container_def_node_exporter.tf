locals {
  container_definition_node_exporter = {
    name              = "node-exporter"
    image             = "prom/node-exporter"

    essential         = true
    memory            = 50
    portMappings      = [
      {
        containerPort = 9100
        hostPort      = 9100
        protocol      = "tcp"
      }
    ]
    mountPoints = [
      {
        sourceVolume  = "node-proc",
        containerPath = "/host/proc",
        readOnly      = true
      },
      {
        sourceVolume  = "node-rootfs",
        containerPath = "/rootfs",
        readOnly      = false
      },
      {
        sourceVolume  = "node-sys",
        containerPath = "/host/sys",
        readOnly      = true
      }
    ]
    command = [
      "--path.procfs=/host/proc",
      "--path.sysfs=/host/sys",
      "--path.rootfs=/rootfs",
      "--collector.netclass.ignored-devices=^(lo|docker[0-9]|kube-ipvs0|dummy0|veth.+|br\\-.+)$",
      "--collector.netdev.device-blacklist=^(lo|docker[0-9]|kube-ipvs0|dummy0|veth.+|br\\-.+)$",
      "--collector.filesystem.ignored-mount-points=^/(dev|sys|proc|host|etc|var/lib/kubelet|var/lib/docker/.+)($|/)",
      "--collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|efivarfs|tmpfs|nsfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rootfs|rpc_pipefs|securityfs|sysfs|tracefs)$",
      "--collector.diskstats.device-exclude=^(ram|loop|fd|(h|s|v|xv)d[a-z]|nvme\\d+n\\d+p|dm-|sr|nbd)\\d+$",
      "--no-collector.systemd",
      "--no-collector.bcache",
      "--no-collector.infiniband",
      "--no-collector.wifi",
      "--no-collector.ipvs"
    ]
    dockerLabels = {
      PROMETHEUS_SCRAPES = "9100"
    }
    logConfiguration = {
      logDriver = "awslogs"
      options   = {
        awslogs-group         = aws_cloudwatch_log_group.for_prometheus.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "node-exporter"
      }
    },
  }
}