data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block_vpc
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(data.aws_availability_zones.available.names, count.index) == "us-east-1a" ? var.cidr_block_public : var.cidr_block_public
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "private_app" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(data.aws_availability_zones.available.names, count.index + 2) == "us-east-1a" ? var.cidr_block_private_app : var.cidr_block_private_app
  map_public_ip_on_launch = false

  tags = {
    Name = "private-app-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "private_db" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(data.aws_availability_zones.available.names, count.index + 4) == "us-east-1a" ? var.cidr_block_private_db : var.cidr_block_private_db
  map_public_ip_on_launch = false

  tags = {
    Name = "private-db-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-internet-gateway"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[1].id

  tags = {
    Name = "main-nat-gateway"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "main-nat-eip"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = 4
  subnet_id      = element(concat(aws_subnet.private_app[*].id, aws_subnet.private_db[*].id), count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}

resource "aws_security_group" "web_server" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-security-group"
  }
}

resource "aws_security_group" "ssh_bastion" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-bastion-security-group"
  }
}

resource "aws_security_group" "db" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-security-group"
  }
}

resource "aws_instance" "web" {
  count           = 2
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_pair_name
  subnet_id       = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.web_server.id]

  tags = {
    Name = "web-instance-${count.index}"
  }

  user_data = <<-EOF
#!/bin/bash

sudo yum update -y
sudo yum install -y httpd

# Enable and start Apache
sudo systemctl enable httpd
sudo systemctl start httpd

# Create a simple index.html
echo "<html><body><h1>Welcome to my web server!</h1></body></html>" | sudo tee /var/www/html/index.html > /dev/null
EOF

}

resource "aws_instance" "app" {
  count           = 2
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_pair_name
  subnet_id       = aws_subnet.private_app[count.index].id
  security_groups = [aws_security_group.web_server.id]

  tags = {
    Name = "app-instance-${count.index}"
  }
}

resource "aws_alb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "main-alb"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = 2
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

output "alb_dns_name" {
  value = aws_alb.main.dns_name
}

resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = concat(aws_subnet.private_db[*].id, aws_subnet.private_app[*].id)
}

resource "aws_rds_cluster" "main" {
  cluster_identifier      = "main-rds-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.2"
  database_name           = "sqldb"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 5
  apply_immediately       = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name

  scaling_configuration {
    auto_pause   = false
    max_capacity = 2
    min_capacity = 1
  }

  tags = {
    Name = "main-rds-cluster"
  }
}
