locals {
  env_config = {
    default = {
      vpc_name           = "default-vpc"
      single_nat_gateway = true
    }
    dev = {
      vpc_name           = "dev-vpc"
      single_nat_gateway = true
    }
    prod = {
      vpc_name           = "prod-vpc"
      single_nat_gateway = true
    }
  }

  config = lookup(
    local.env_config,
    terraform.workspace,
    local.env_config["default"]
  )
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = local.config.vpc_name
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.config.vpc_name}-public-${count.index + 1}"
    Environment = terraform.workspace
    Type        = "public"
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name        = "${local.config.vpc_name}-private-${count.index + 1}"
    Environment = terraform.workspace
    Type        = "private"
    ManagedBy   = "terraform"
  }

}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name        = "${local.config.vpc_name}-igw"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }
}

resource "aws_eip" "nat" {
  count  = local.config.single_nat_gateway ? 1 : length(var.public_subnet_cidr)
  domain = "vpc"
  tags = {
    Name        = "${local.config.vpc_name}-nat-eip-${count.index + 1}"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }

  depends_on = [aws_internet_gateway.my_igw]
}


resource "aws_nat_gateway" "my_ngw" {
  count         = local.config.single_nat_gateway ? 1 : length(var.public_subnet_cidr)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name        = "${local.config.vpc_name}-nat-${count.index + 1}"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }
  depends_on = [aws_internet_gateway.my_igw]

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name        = "${local.config.vpc_name}-public-rt"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # dev   → all private subnets use same single NAT
    # prod  → each private subnet uses its own NAT
    nat_gateway_id = local.config.single_nat_gateway ? aws_nat_gateway.my_ngw[0].id : aws_nat_gateway.my_ngw[count.index].id
  }

  tags = {
    Name        = "${local.config.vpc_name}-private-rt-${count.index + 1}"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }
}

# associate private route table with private subnets
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
