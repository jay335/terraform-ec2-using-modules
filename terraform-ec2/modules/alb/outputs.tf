output "alb_name" {
	description = "Dns name of ALB"
	value = aws_lb.my_alb.dns_name
}

output "alb_arn" {
	description = "ARN of ALB" 
	value = aws_lb.my_alb.arn
}

output "alb_zone_id" {
	description = "Zone ID of ALB"
	value = aws_lb.my_alb.zone_id
}

output "target_group_arn" {
	description = "ARN of target group"
	value = aws_lb_target_group.my_target.arn
}

output "alb_security_group_id" {
	description = "Security group ID of ALB"
	value = aws_security_group.alb_sg.id
}
