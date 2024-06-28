output "vpc_id" {
  value = aws_vpc.two_tier_vpc.id
}
output "public_subnet_ids" {
  value = aws_subnet.two_tier_public_subnet.*.id 
}
output "private_subnet_ids" {
  value = aws_subnet.two_tier_private_subnet.*.id 
}
output "asg_sg_id" {
  value = aws_security_group.two_tier_asg_sg.id
}
output "elb_sg_id" {
  value = aws_security_group.two_tier_elb_sg.id
}
output "rds_sg_id" {
  value = aws_security_group.two_tier_rds_sg.id
}