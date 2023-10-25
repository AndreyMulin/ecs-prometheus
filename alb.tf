resource "aws_lb" "prom" {
  name               = "prom"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.pub_subnet-1.id, aws_subnet.pub_subnet-2.id]

  enable_deletion_protection = false
}

# Node exporter
resource "aws_alb_target_group" "node_exporter" {
  name        = "tg-node-exporter"
  port        = 9100
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "5"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "listen_9100" {
  load_balancer_arn = aws_lb.prom.id
  port              = 9100
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.node_exporter.id
    type             = "forward"
  }
}

# Prometheus
resource "aws_alb_target_group" "prom" {
  name        = "tg-prometheus"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/-/healthy"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "listen_9090" {
  load_balancer_arn = aws_lb.prom.id
  port              = 9090
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.prom.id
    type             = "forward"
  }
}

# Cadvisor
resource "aws_alb_target_group" "cadvisor" {
  name        = "tg-cadvisor"
  port        = 9101
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-399"
    timeout             = "3"
    path                = "/docker/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "listen_9101" {
  load_balancer_arn = aws_lb.prom.id
  port              = 9101
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.cadvisor.id
    type             = "forward"
  }
}

# Cloudwatch_exporter
resource "aws_alb_target_group" "cloudwatch" {
  name        = "tg-cloudwatch"
  port        = 9106
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-399"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "listen_9106" {
  load_balancer_arn = aws_lb.prom.id
  port              = 9106
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.cloudwatch.id
    type             = "forward"
  }
}