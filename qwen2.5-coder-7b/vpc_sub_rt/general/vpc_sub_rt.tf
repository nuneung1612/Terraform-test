data "aws_availability_zones" "available" {}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "main-vpc" }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "main-igw" }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_subnet" "public" {
  count                   = 2
  availability_zone       = element(local.azs, count.index)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = ["10.0.0.0/24", "10.0.1.0/24"][count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = format("Public Subnet AZ %d", count.index + 1) }
}

resource "aws_subnet" "private" {
  count             = 2
  availability_zone = element(local.azs, count.index)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = ["10.0.10.0/24", "10.0.11.0/24"][count.index]
  tags              = { Name = format("Private Subnet AZ %d", count.index + 1) }
}

resource "aws_eip" "nat" {
  count = 2
  tags  = { Name = format("NAT EIP %d", count.index + 1) }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = { Name = format("NAT GW %d", count.index + 1) }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = { Name = "Public Route Table" }
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = { Name = format("Private Route Table AZ %d", count.index + 1) }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
