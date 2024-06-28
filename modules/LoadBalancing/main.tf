resource "aws_lb" "two_tier_lb" {
  name                  = "${var.resource_name}-lb"
  internal              = false
  load_balancer_type    = "application"
  security_groups       = [ "${var.elb_sg_id}" ]
  subnets               = [ "${var.public_subnet}" ]
}

resource "aws_lb_target_group" "two_tier_tg" {
  name      = "${var.resource_name}-tg"
  port      = "${var.http_port}"
  protocol  = "${var.protocol}"
  vpc_id    = "${var.vpc_id}"
}

resource "aws_lb_listener" "two_tier_lb_listener" {
  load_balancer_arn = "${aws_lb.two_tier_lb.arn}"
  port              = "${var.http_port}"
  protocol          = "${var.protocol}"
  default_action {
    type                = "forward"
    target_group_arn    = aws_lb_target_group.two_tier_tg.arn
  }
}