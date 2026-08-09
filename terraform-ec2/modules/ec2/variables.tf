variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI ID for us-east-1"
  type        = string
  default     = "ami-0e86e20dae9224db8"
}

variable "key_name" {
  description = "AWS Key pair name for SSH"
  type        = string
  default     = "my-key-pair"
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "web-server"
}

variable "vpc_id" {
	description = "Vpc id of vpc module"
	type = string
}

variable "private_subnet_ids" {
	description = "Private subnet ids from vpc module"
	type = list(string)
}
