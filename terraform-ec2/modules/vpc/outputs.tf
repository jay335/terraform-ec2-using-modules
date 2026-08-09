output "vpc_id" {
	description = "ID of the VPC"
	value = aws_vpc.my_vpc.id
}

output "vpc_cidr" {
	description = "CIDR block of VPC"
	value = aws_vpc.my_vpc.cidr_block
}

output "public_subnet_ids" {
	description = "List of public subnets"
	value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
	description = "List of private subnets"
	value = aws_subnet.private[*].id
}

output "internet_gateway_id" {
	description = "Internet gateway id"
	value = aws_internet_gateway.my_igw.id
}

output "nat_gateway_id" {
	description = "Natgateway Id"
	value = aws_nat_gateway.my_ngw[*].id
}

output "public_route_table_id" {
	description = "public route table" 
	value = aws_route_table.public.id
}

output "private_route_table" {
	description = "private route table"
	value = aws_route_table.private[*].id
}
