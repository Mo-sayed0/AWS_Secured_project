#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

#Define the VPC
resource "aws_vpc" "vpc_ـHA_3-Tire" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "var.vpc_ـHA_3-Tire"
    Environment = "demo_environment"
  }
}

#Deploy the private subnets
resource "aws_subnet" "private_subnets_HA" {
  for_each          = "var.private_subnets"
  vpc_id            = aws_vpc.vpc_ـHA_3-Tire.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name  = "Private_Subnet_HA_3-Tire"
    Group = "DolfenEd"
  }
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets_HA" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc_ـHA_3-Tire.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name  = "Public_Subnet_HA_3-Tire"
    Group = "DolfenEd"
  }
}

#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_ـHA_3-Tire.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "Public_rtb_HA"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_ـHA_3-Tire.id

  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id     = aws_internet_gateway.internet_gateway.id
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "private_rtb_HA"
  }
}

#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc_ـHA_3-Tire.id
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
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name = "Nat_gateway_HA_3-tire"
  }
}
