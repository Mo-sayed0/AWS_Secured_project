
# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
  }
}

# Subnets
resource "aws_subnet" "private_subnets" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 6)
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  tags = {
    Name      = "Private_Subnet_${count.index + 1}"
    Terraform = "true"
  }
}

resource "aws_subnet" "private_subnets_db" {
  count             = var.private_subnet_count_db
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + var.private_subnet_count)
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  tags = {
    Name      = "Private_Subnet_db_${count.index + 1}"
    Terraform = "true"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + var.private_subnet_count + var.private_subnet_count_db)
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true
  tags = {
    Name      = "Public_Subnet_${count.index + 1}"
    Terraform = "true"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw_HA_3-Tier"
  }
}

# NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "igw_eip_HA_3-Tier"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "nat_gateway_HA_3-Tier"
  }
}

# Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name      = "public_rtb_HA_3-Tier"
    Terraform = "true"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "Private_rtb_HA_3-Tier"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.private_subnet_count
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_route_table_association" "private_db" {
  count          = var.private_subnet_count_db
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnets_db[count.index].id
}
