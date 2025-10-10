

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  count             = 2
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  vpc_id            = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = {
    Name = "public-${count.index + 1}"
  }
}

resource "aws_subnet" "private_app" {
  count             = 2
  cidr_block        = var.private_subnets_cidr_app[count.index]
  availability_zone = var.availability_zones[count.index]
  vpc_id            = aws_vpc.main.id
  tags = {
    Name = "private-app-${count.index + 1}"
  }
}

resource "aws_subnet" "private_db" {
  count             = 2
  cidr_block        = var.private_subnets_cidr_db[count.index]
  availability_zone = var.availability_zones[count.index]
  vpc_id            = aws_vpc.main.id
  tags = {
    Name = "private-db-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[1].id
  tags = {
    Name = "main"
  }
}

resource "aws_eip" "main" {
  vpc = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private"
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private_app" {
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db" {
  count          = 2
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private.id
}
