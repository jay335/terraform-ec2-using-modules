output "instance_id" {
  description = "EC2 instance id"
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "Public IP of Ec2"
  value       = module.ec2.public_ip
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = module.ec2.ssh_command
}

output "environment" {
  description = "Current Workspace environment"
  value       = terraform.workspace
}

output "vpc" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet Ids"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private Subnet Ids"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.nat_gateway_id
}

output "alb_name" {
  description = "ALB Name"
  value       = module.alb.alb_name
}

