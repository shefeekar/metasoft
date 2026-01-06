variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  description = "Allowed CIDR blocks for SSH"
}

variable "MY_SECRET_NUMBER" {
  type        = string
  sensitive   = true
  description = "Secret number for Node.js app"
}
