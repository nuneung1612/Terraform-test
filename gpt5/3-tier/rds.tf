// rds.tf
resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnet-group"
  subnet_ids = [for s in aws_subnet.db : s.id]
  tags       = merge(var.tags, { Name = "db-subnet-group" })
}

resource "aws_db_instance" "mysql" {
  identifier             = "mysql-3tier"
  engine                 = "mysql"
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance_class
  allocated_storage      = 10
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  multi_az               = var.rds_multi_az
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  availability_zone      = var.rds_multi_az ? null : local.azs[1] # us-east-1b when single-AZ

  depends_on = [aws_db_subnet_group.db_subnets, aws_security_group.db_sg]

  tags = merge(var.tags, { Name = "mysql-3tier" })
}
