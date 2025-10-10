resource "aws_subnet" "public_subnets" {
  count             = 2
  cidr_block        = element(var.public_subnets_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public_subnets_us_east_1b" {
  count             = 2
  cidr_block        = element(var.public_subnets_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 3}"
  }
}

resource "aws_subnet" "private_app_subnets" {
  count             = 2
  cidr_block        = element(var.private_app_subnets_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-app-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_app_subnets_us_east_1b" {
  count             = 2
  cidr_block        = element(var.private_app_subnets_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-app-subnet-${count.index + 3}"
  }
}

resource "aws_subnet" "private_database_subnets" {
  count             = 2
  cidr_block        = element(var.private_database_subnets_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-database-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_database_subnets_us_east_1b" {
  count             = 2
  cidr_block        = element(var.private_database_subnets_cidr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-database-subnet-${count.index + 3}"
  }
}
