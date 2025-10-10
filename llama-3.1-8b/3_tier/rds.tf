resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "3-tier-db-subnet-group"
  subnet_ids = [aws_subnet.private_database_subnets[0].id, aws_subnet.private_database_subnets_us_east_1b[0].id]
}

resource "aws_db_instance" "db_instance" {
  allocated_storage    = var.db_allocated_storage
  engine               = "mysql"
  instance_class       = var.db_instance_class
  name                 = "sqldb"
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot  = true
  availability_zone    = "us-east-1b"
  multi_az             = var.multi_az
  tags = {
    Name = "3-tier-db-instance"
  }
}
