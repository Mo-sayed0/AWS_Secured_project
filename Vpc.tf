#Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
  }
}

#Deploy the private subnets for us-east-1a subnet1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = var.availability_zone.availability_zone_1a

  tags = {
    Name      = "Priavet_Subnet_1"
    Terraform = "true"
  }
}

#Deploy the private subnets for us-east-1a subnet3
resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.160.0/20"
  availability_zone = var.availability_zone.availability_zone_1a

  tags = {
    Name      = "Priavet_Subnet_3"
    Terraform = "true"
  }
}

#Deploy the public subnets us-east-1a
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = var.availability_zone.availability_zone_1a
  map_public_ip_on_launch = true

  tags = {
    Name      = "public_subnet_1"
    Terraform = "true"
  }
}

#Deploy the private subnets for us-east-1b
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = var.availability_zone.availability_zone_1b

  tags = {
    Name      = "Priavet_Subnet_2"
    Terraform = "true"
  }
}

#Deploy the private subnets for us-east-1b
resource "aws_subnet" "private_subnet_4" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.176.0/20"
  availability_zone = var.availability_zone.availability_zone_1b

  tags = {
    Name      = "Priavet_Subnet_4"
    Terraform = "true"
  }
}

#Deploy the public subnets for us-east-1b
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = var.availability_zone.availability_zone_1b
  map_public_ip_on_launch = true

  tags = {
    Name      = "public_subnet_2"
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
  subnet_id     = aws_subnet.public_subnet_1.id
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

#Create route table associations
resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1.id
}
resource "aws_route_table_association" "public_2" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_2.id
}

resource "aws_route_table_association" "private_1" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_1.id
}

resource "aws_route_table_association" "private_2" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_2.id
}

resource "aws_route_table_association" "private_3" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_3.id
}

resource "aws_route_table_association" "private_4" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_4.id
}
