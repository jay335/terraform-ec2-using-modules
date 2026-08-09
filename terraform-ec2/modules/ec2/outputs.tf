output "instance_id" {
  description = "EC2 instance Id"
  value       = aws_instance.my_ec2.id
}

output "public_ip" {
  description = "Ec2 instance public ip"
  value       = aws_instance.my_ec2.public_ip
}

output "instance_state" {
  description = "EC2 instance state"
  value       = aws_instance.my_ec2.instance_state
}

output "ssh_command" {
  description = "SSh command to connect to EC2"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubutnu@${aws_instance.my_ec2.public_ip}"
}