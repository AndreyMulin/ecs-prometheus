data "aws_ami" "amazon_linux_ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*-x86_64*"]
  }
}

# Private

resource "aws_launch_template" "ecs_launch_config-priv" {
  image_id               = data.aws_ami.amazon_linux_ami.id
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  instance_type          = "t2.medium"
  key_name               = "andrey_mulin_monitoring_account"
  user_data              = filebase64("templates/user_data.sh")
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }
}

resource "aws_autoscaling_group" "prometheus_ecs_asg-priv" {
  name                      = "asg-priv"
  vpc_zone_identifier       = [aws_subnet.priv-subnet-1.id, aws_subnet.priv-subnet-2.id]
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ecs_launch_config-priv.id
      }

      override {
        instance_type     = "t2.medium"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "t2.small"
        weighted_capacity = "2"
      }
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# Public aws_launch_configuration

resource "aws_launch_template" "ecs_launch_config-pub" {
  image_id = data.aws_ami.amazon_linux_ami.id

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs_sg.id]
  }

  instance_type          = "t2.medium"
  key_name               = "andrey_mulin_monitoring_account"
  update_default_version = true
}

resource "aws_autoscaling_group" "prometheus_ecs_asg-pub" {
  name                      = "asg-pub"
  vpc_zone_identifier       = [aws_subnet.pub_subnet-1.id, aws_subnet.pub_subnet-2.id]
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"


  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ecs_launch_config-pub.id
      }

      override {
        instance_type     = "t2.medium"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "t2.large"
        weighted_capacity = "2"
      }
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
