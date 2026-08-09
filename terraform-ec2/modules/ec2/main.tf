locals {

  env_config = {
    default = {
      instance_type = "t2.micro"
      volume_size   = 20
    }
    dev = {
      instance_type = "t2.micro"
      volume_size   = 20
    }

    prod = {
      instance_type = "t2.micro"
      volume_size   = 20
    }
  }

  config = lookup(
    local.env_config,
    terraform.workspace,
    local.env_config["default"]
  )

  instance_name = "${terraform.workspace}-${var.instance_name}"
}


resource "aws_iam_role" "ec2_role" {
	name = "${local.instance_name}-role"
	assume_role_policy = jsonencode({
		version = "2012-10-17"
		Statement = [
			{
				Effect = "Allow"
				Principal = {
					service = "ec2.amazonaws.com"
				}
				Action = "sts:AssumeRole"	
			}
		]
	})

	tags = {
    		Name        = "${local.instance_name}-role"
    		Environment = terraform.workspace
    		ManagedBy   = "terraform"
  	}
}


resource "aws_iam_role_policy_attachment" "ssm" {
	role = aws_iam_role.ec2_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# S3 read only — read config files from S3 if needed
resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
	name = "${local.instance_name}--profile"
	role = aws_iam_role.ec2_role.name
	
	 tags = {
   		 Name        = "${local.instance_name}-profile"
   		 Environment = terraform.workspace
    		 ManagedBy   = "terraform"
  	}
}

resource "aws_security_group" "ec2_sg" {

  name        = "${local.instance_name}-sg"
  description = "security group for ${local.instance_name}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_instance" "my_ec2" {
  ami                    = var.ami_id
  instance_type          = local.config.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  root_block_device {
    volume_size           = local.config.volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<EOF
		#!/bin/bash
		apt-get update -y
		apt-get install -y nginx
		systemctl start nginx
		systemctl enable nginx
		echo "<h1>${local.instance_name} is running in ${terraform.workspace} environment</h1>" > /var/www/html/index.html
	EOF

  tags = {
    Name        = local.instance_name
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }

}
