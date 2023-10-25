resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"/**/
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Prometheus role
resource "aws_iam_role" "ecs_prometheus" {
  name               = "ecs-prometheus"
  assume_role_policy = data.aws_iam_policy_document.ecs_prometheus.json
}

data "aws_iam_policy_document" "ecs_prometheus" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

# AppConfig
data "aws_iam_policy_document" "app_config_allow" {
  statement {
    effect = "Allow"
    actions = [
      "appconfig:GetLatestConfiguration",
      "appconfig:StartConfigurationSession",
    ]
    resources = [
      aws_appconfig_application.prometheus.arn,
      "${aws_appconfig_application.prometheus.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "app_config_allow" {
  name   = "Prometheus-AppConfig-access"
  path   = "/"
  policy = data.aws_iam_policy_document.app_config_allow.json
}

resource "aws_iam_role_policy_attachment" "app_config_allow" {
  policy_arn = aws_iam_policy.app_config_allow.arn
  role       = aws_iam_role.ecs_prometheus.name
}


# ECS-Discovery
resource "aws_iam_policy" "service_discovery_allow" {
  name   = "service-discovery-access"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs.json
}

data "aws_iam_policy_document" "ecs" {
  statement {
    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeContainerInstances",
      "ecs:DescribeTask",
      "ecs:DescribeTasks",
      "EC2:DescribeInstances",
      "ecs:DescribeTaskDefinition",
      "ecs:ListServices",
      "ecs:ListTasks",
      "ecs:ListClusters",
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs-discovery" {
  policy_arn = aws_iam_policy.service_discovery_allow.arn
  role       = aws_iam_role.ecs_prometheus.name
}

# CloudWatch
resource "aws_iam_policy" "service_cloudwatch_allow" {
  name   = "service-cloudwatch-access"
  path   = "/"
  policy = data.aws_iam_policy_document.cloudwatch.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = aws_iam_policy.service_cloudwatch_allow.arn
  role       = aws_iam_role.ecs_prometheus.name
}

# Parameter Store
resource "aws_iam_role" "get_secrets" {
  name               = "get_secrets"
  assume_role_policy = data.aws_iam_policy_document.get_secrets_role.json
}

data "aws_iam_policy_document" "get_secrets_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "get_secrets" {
  name   = "get_secrets"
  path   = "/"
  policy = data.aws_iam_policy_document.get_secrets.json
}

data "aws_iam_policy_document" "get_secrets" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "ssm:GetParameters",
    ]
    effect = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    effect = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "get_secrets" {
  policy_arn = aws_iam_policy.get_secrets.arn
  role       = aws_iam_role.get_secrets.name
}