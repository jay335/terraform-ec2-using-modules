variable "vpc_id" {
	description = "VPC id from vpc module"
	type = string
}

variable "public_subnet_ids" {
	description = "Public subnet ids from vpc module"
	type = list(string)
}

variable "instance_id" {
	description = "EC2 instance id from ec2 module"
	type = string
}

variable "target_port" {
	description = "Port of the ec2 is listening on"
	type = number
	default = 80
}

variable "health_check_path" {
	description = "Health Check Path"
	type = string
	default = "/"
}


