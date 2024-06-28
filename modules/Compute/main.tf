data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["azmzn2-ami-hvm-*-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_template" "two_tier_app_launch_template" {
  name                      = "${var.resource_name}-launch-template"
  instance_type             = "${var.instance_type}"
  image_id                  = "${data.aws_ami.amazon_linux_ami.id}"
  vpc_security_group_ids    = [ "${var.asg_sg_id}" ]
  key_name                  = "TwoTierKeyPair"
  user_data                 = filebase64("${path.root}/install_nginx.sh")
  tags = {
    "Name" = "${var.resource_name}-launch-template"
  }
}

resource "aws_autoscaling_group" "two_tier_app_asg" {
  name                  = "${var.resource_name}-asg"
  min_size              = 2
  max_size              = 4
  desired_capacity      = 2
  vpc_zone_identifier   = [ "${var.public_subnet}" ]
  target_group_arns     = [ "${var.elb_tg_arn}" ]
  lifecycle {
    create_before_destroy = true
  }
  launch_template {
    id      = "${aws_launch_template.two_tier_app_launch_template.id}"
    version = "$Latest"
  }
}