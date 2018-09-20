## Data
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

output "amazon-linux-2_ami_id" {
  value = "${data.aws_ami.amazon-linux-2.id}"
}

## Variables
# Provider
variable "access_key" {}

variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

# VPC
data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

variable "vpc_id" {}

# Subnet1
data "aws_subnet" "subnet" {
  id = "${var.subnet_id}"
}

variable "subnet_id" {}

# Tags
variable "name" {}

variable "env" {}

variable "owner" {}

# Instances
variable "count" {
  default = "2"
}

variable "ami" {
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
}

variable "disable_api_termination" {
  default = "false"
}

variable "associate_public_ip_address" {
  default = "true"
}

# Root Disk
variable "root_volume_type" {
  default = "gp2"
}

variable "root_volume_size" {
  default = "10"
}

variable "root_delete_on_termination" {
  default = "true"
}

# Data Disk
variable "data_volume_type" {
  default = "gp2"
}

variable "data_volume_size" {
  default = "10"
}

variable "data_device_name" {
  default = "/dev/xvdb"
}

variable "snapshot_id" {
}
