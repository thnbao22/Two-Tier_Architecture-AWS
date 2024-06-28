output "elb_tg_name" {
  value = aws_lb_target_group.two_tier_tg.name
}
output "elb_tg_arn" {
  value = aws_lb_target_group.two_tier_tg.arn
}
output "elb_dns_name" {
  value = aws_lb.two_tier_lb.dns_name
}