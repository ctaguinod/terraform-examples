resource "aws_instance" "instances" {
  count                       = "${var.count}"
  ami                         = "${data.aws_ami.amazon-linux-2.id}" # "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.key_pair.key_name}" # "${var.key_name}"
  subnet_id                   = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.instance-sg.id}"] # Replace with existing Security Group Ids
  disable_api_termination     = "${var.disable_api_termination}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${data.template_file.user-data.rendered}"

  tags {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.name}${count.index}"
  }

  volume_tags {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.name}${count.index}-root"
  }

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_delete_on_termination}"
  }

  lifecycle {
    ignore_changes = ["ami", "user_data", "volume_tags"]
  }

  depends_on = ["aws_ebs_volume.volume-data"]
}

# Create EBS Volume from Snapshot (var.snapshot_id) for Data Volume
resource "aws_ebs_volume" "volume-data" {
  snapshot_id       = "${var.snapshot_id}"
  count             = "${var.count}"
  availability_zone = "${data.aws_subnet.subnet.availability_zone}"
  type              = "${var.data_volume_type}"
  size              = "${var.data_volume_size}"

  tags {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.name}${count.index}-data"
  }
}

resource "aws_volume_attachment" "volume-data-attachment" {
  count       = "${var.count}"
  device_name = "${var.data_device_name}"
  volume_id   = "${element(aws_ebs_volume.volume-data.*.id, count.index)}"
  instance_id = "${element(aws_instance.instances.*.id, count.index)}"
}

# User Data
data "template_file" "user-data" {
  template = "${file("user-data.sh")}"
}

# Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.owner}_key_pair"
  public_key = "${data.template_file.ssh_public_key.rendered}"
}

# SSH Public Key
data "template_file" "ssh_public_key" {
  template = "${file("~/.ssh/id_rsa.pub")}"
}

# EC2 Instance Security Group
resource "aws_security_group" "instance-sg" {
  description = "EC2 Instance Security Group"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.owner}-${var.env}-instance-sg"
  }

  # Allow SSH Traffic from workstation IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.workstation-external-cidr}"]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic from same Security Group
  #ingress {
  #  from_port = 0
  #  to_port   = 0
  #  protocol  = "-1"
  #  self      = "true"
  #}

  // Allow HTTP/HTTPS from ALB
  #ingress {
  #  from_port       = 80
  #  to_port         = 80
  #  protocol        = "tcp"
  #  security_groups = ["${aws_security_group.alb-sg.id}"]
  #}

  #ingress {
  #  from_port       = 443
  #  to_port         = 443
  #  protocol        = "tcp"
  #  security_groups = ["${aws_security_group.alb-sg.id}"]
  #}
}

# Outputs
output "private_ips" {
  value = ["${aws_instance.instances.*.private_ip}"]
}

output "public_ips" {
  value = ["${aws_instance.instances.*.public_ip}"]
}

output "ids" {
  value = ["${aws_instance.instances.*.id}"]
}
