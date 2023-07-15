variable "key" {
  type        = string
  description = "Key to login to EC2 instance"
}

variable "ami" {
  type        = string
  description = "AMI for the instance"
}

variable "instance_type" {
  type        = string
  description = "Type of EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet Id to deploy EC2 instance"
}

variable "instance_name" {
  type        = string
  description = "Name of EC2 instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "region" {
  type        = string
  description = "Region to deploy the instance"
}