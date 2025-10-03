provider "aws" {
  region = "us-east-1" # Change to your desired region
}

data "aws_availability_zones" "available" {}

# 1. Create a VPC named main-vpc with CIDR block 10.0.0.0/16 and enable DNS hostnames.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# 2. Create an Internet Gateway named main-igw and attach it to the VPC.
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# 3. Create 2 Public Subnets (one per AZ):
resource "aws_subnet" "public_subnet" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(["10.0.0.0/24", "10.0.1.0/24"], count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet AZ ${count.index + 1}"
  }
}

# 4. Create 2 Private Subnets (one per AZ):
resource "aws_subnet" "private_subnet" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(["10.0.10.0/24", "10.0.11.0/24"], count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "Private Subnet AZ ${count.index + 1}"
  }
}

# 5. Allocate 2 Elastic IPs for NAT Gateways.
resource "aws_eip" "nat_eip" {
  count = 2
}

# 6. Create 2 NAT Gateways (one per AZ):
resource "aws_nat_gateway" "nat_gateway" {
  count = 2

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "NAT Gateway AZ ${count.index + 1}"
  }
}

# 7. Create Route Tables:
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private" {
  count = 2

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "Private Route Table AZ ${count.index + 1}"
  }
}

# 8. Associate Route Tables:
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
