#Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
  }
}

# Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 8)
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = {
    Name      = "Private_Subnet_${count.index + 1}"
    Terraform = "true"
  }
}

# Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 5)
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    Name      = "public_Subnet_${count.index + 1}"
    Terraform = "true"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw_HA_3-Tire"
  }
}

#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "igw_eip_HA_3-Tire"
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "nat_gateway_HA_3-Tire"
  }
}

#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "public_rtb_HA_3-Tire"
    Terraform = "true"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    #gateway_id     = aws_internet_gateway.internet_gateway.id
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "Private_rtb_HA_3-Tire"
    Terraform = "true"
  }
}

# Create route table associations
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
