# Data source to get availability zones
data "aws_availability_zones" "available" {}

# VPC configuration
resource "aws_vpc" "main-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway configuration
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "main-igw"
  }
}

# Public Subnet 1 configuration
resource "aws_subnet" "public-subnet-az1" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.main-vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet AZ 1"
  }
}

# Public Subnet 2 configuration
resource "aws_subnet" "public-subnet-az2" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.main-vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet AZ 2"
  }
}

# Private Subnet 1 configuration
resource "aws_subnet" "private-subnet-az1" {
  cidr_block        = "10.0.10.0/24"
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Private Subnet AZ 1"
  }
}

# Private Subnet 2 configuration
resource "aws_subnet" "private-subnet-az2" {
  cidr_block        = "10.0.11.0/24"
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "Private Subnet AZ 2"
  }
}

# Elastic IP 1 configuration
resource "aws_eip" "nat-gateway-az1" {
  vpc = true
}

# Elastic IP 2 configuration
resource "aws_eip" "nat-gateway-az2" {
  vpc = true
}

# NAT Gateway 1 configuration
resource "aws_nat_gateway" "nat-gateway-az1" {
  allocation_id = aws_eip.nat-gateway-az1.id
  subnet_id     = aws_subnet.public-subnet-az1.id
  tags = {
    Name = "NAT Gateway AZ 1"
  }
}

# NAT Gateway 2 configuration
resource "aws_nat_gateway" "nat-gateway-az2" {
  allocation_id = aws_eip.nat-gateway-az2.id
  subnet_id     = aws_subnet.public-subnet-az2.id
  tags = {
    Name = "NAT Gateway AZ 2"
  }
}

# Public Route Table configuration
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "Public Route Table"
  }
}

# Public Route configuration
resource "aws_route" "public-rt-igw" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-igw.id
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public-rt-subnet-az1" {
  subnet_id      = aws_subnet.public-subnet-az1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-rt-subnet-az2" {
  subnet_id      = aws_subnet.public-subnet-az2.id
  route_table_id = aws_route_table.public-rt.id
}

# Private Route Table 1 configuration
resource "aws_route_table" "private-rt-az1" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "Private Route Table AZ 1"
  }
}

# Private Route configuration for NAT Gateway 1
resource "aws_route" "private-rt-az1-nat" {
  route_table_id         = aws_route_table.private-rt-az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway-az1.id
}

# Associate Private Route Table 1 with Private Subnet 1
resource "aws_route_table_association" "private-rt-az1-subnet" {
  subnet_id      = aws_subnet.private-subnet-az1.id
  route_table_id = aws_route_table.private-rt-az1.id
}

# Private Route Table 2 configuration
resource "aws_route_table" "private-rt-az2" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "Private Route Table AZ 2"
  }
}

# Private Route configuration for NAT Gateway 2
resource "aws_route" "private-rt-az2-nat" {
  route_table_id         = aws_route_table.private-rt-az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway-az2.id
}

# Associate Private Route Table 2 with Private Subnet 2
resource "aws_route_table_association" "private-rt-az2-subnet" {
  subnet_id      = aws_subnet.private-subnet-az2.id
  route_table_id = aws_route_table.private-rt-az2.id
}
