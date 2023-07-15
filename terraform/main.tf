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

resource "aws_security_group" "ingress-all-test" {
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

resource "aws_instance" "ec2_instance" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  tags = {
    Name = var.instance_name
  }
  subnet_id = var.subnet_id
  user_data = "${file("install_dependencies.sh")}"
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

}

output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}