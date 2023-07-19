terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

resource "aws_security_group" "ingress-all" {
  name = "allow-all-sg"
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "nw-5g" {
  name_prefix     = "aws-asg-launch-configuration"
  image_id        = var.ami
  instance_type   = var.instance_type
  user_data       = "${file("install_dependencies.sh")}"
  security_groups = ["${aws_security_group.ingress-all.id}"]
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nw-5g" {
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.nw-5g.name
  vpc_zone_identifier  = [var.subnet_id]
}

resource "aws_lb" "nw-5g" {
  name               = "nw-5g-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.ingress-all.id}"]
  subnets            = ["subnet-0344b6e91a4655d08","subnet-00ba09388043d53b9","subnet-0d44db98a5e6fd16c"]
}

resource "aws_lb_listener" "webui" {
  load_balancer_arn = aws_lb.nw-5g.arn
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webui.arn
  }
}
resource "aws_lb_target_group" "webui" {
  name     = "tg-webui"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "prometheus" {
  load_balancer_arn = aws_lb.nw-5g.arn
  port              = "9090"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}

resource "aws_lb_target_group" "prometheus" {
  name     = "tg-prometheus"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "cadvisor" {
  load_balancer_arn = aws_lb.nw-5g.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cadvisor.arn
  }
}

resource "aws_lb_target_group" "cadvisor" {
  name     = "tg-cadvisor"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "node_exporter" {
  load_balancer_arn = aws_lb.nw-5g.arn
  port              = "9100"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node_exporter.arn
  }
}

resource "aws_lb_target_group" "node_exporter" {
  name     = "tg-node-exporter"
  port     = 9100
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_autoscaling_attachment" "webui" {
  autoscaling_group_name = aws_autoscaling_group.nw-5g.id
  alb_target_group_arn   = aws_lb_target_group.webui.arn
}

resource "aws_autoscaling_attachment" "prometheus" {
  autoscaling_group_name = aws_autoscaling_group.nw-5g.id
  alb_target_group_arn   = aws_lb_target_group.prometheus.arn
}

resource "aws_autoscaling_attachment" "cadvisor" {
  autoscaling_group_name = aws_autoscaling_group.nw-5g.id
  alb_target_group_arn   = aws_lb_target_group.cadvisor.arn
}

resource "aws_autoscaling_attachment" "node_exporter" {
  autoscaling_group_name = aws_autoscaling_group.nw-5g.id
  alb_target_group_arn   = aws_lb_target_group.node_exporter.arn
}


output "public_dns" {
  value = aws_lb.nw-5g.dns_name
}
