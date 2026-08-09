locals {
	env_config = {
		default = {
			alb_name = "default-web-alb"
		}
		dev = {
			alb_name = "dev-web-alb"
		}
		prod = {
			alb_name = "prod-web-alb"
		}
	}
	
	config = lookup (
	  local.env_config,
	  terraform.workspace,
	  local.env_config["default"]
	)

}

resource "aws_security_group" "alb_sg" {
	name = "${local.config.alb_name}-sg"
	description = "Security group for ALB"
	vpc_id = var.vpc_id
	
	ingress {
	  	description = "HTTP"
	 	from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		description = "HTTPS"
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = -1
		cidr_blocks = ["0.0.0.0/0"]
	}

	 tags = {
    		Name        = "${local.config.alb_name}-sg"
    		Environment = terraform.workspace
    		ManagedBy   = "terraform"
  }
}

resource "aws_lb" "my_alb" {
	name = local.config.alb_name
	internal = false
	load_balancer_type = "application"
	security_groups = [aws_security_group.alb_sg.id]
	subnets = var.public_subnet_ids

	enable_deletion_protection = false

	tags = {
   	  Name        = local.config.alb_name
    	  Environment = terraform.workspace
          ManagedBy   = "terraform"
  	}
}


resource "aws_lb_target_group" "my_target" {
	name = "${local.config.alb_name}-tg"
	port = var.target_port
	protocol = "HTTP"
	vpc_id = var.vpc_id
	
	
	health_check {
		enabled = true
		path = var.health_check_path
		port = "traffic-port"
		protocol = "HTTP"
		healthy_threshold = 2
		unhealthy_threshold = 3
		timeout = 5
		interval = 30
		matcher = "200"
	}

	tags = {
   		 Name  = "${local.config.alb_name}-tg"
    		 Environment = terraform.workspace
    		 ManagedBy   = "terraform"
  	}
}


resource "aws_lb_target_group_attachment" "target_attach" {
	target_group_arn = aws_lb_target_group.my_target.arn
	target_id = var.instance_id
	port = var.target_port
}

resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.my_alb.arn
	port = 80
	protocol = "HTTP"

	default_action {
		type = "forward"
		target_group_arn = aws_lb_target_group.my_target.arn
	}

	tags = {
   		 Name        = "${local.config.alb_name}-listener"
    		 Environment = terraform.workspace
    		 ManagedBy   = "terraform"
  	}
}


