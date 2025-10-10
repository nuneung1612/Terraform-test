resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = 2
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_us_east_1b" {
  count          = 2
  subnet_id      = element(aws_subnet.public_subnets_us_east_1b.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = 4
  subnet_id      = element(aws_subnet.private_app_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_us_east_1b" {
  count          = 4
  subnet_id      = element(aws_subnet.private_app_subnets_us_east_1b.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_database_route_table_association" {
  count          = 4
  subnet_id      = element(aws_subnet.private_database_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_database_route_table_association_us_east_1b" {
  count          = 4
  subnet_id      = element(aws_subnet.private_database_subnets_us_east_1b.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}
