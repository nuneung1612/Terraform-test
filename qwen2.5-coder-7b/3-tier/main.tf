variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "web_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the Web Tier subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the App Tier subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the Database Tier subnets"
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "instance_type" {
  type        = string
  description = "Instance type for EC2 instances"
  default     = "t2.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances"
  default     = "ami-052064a798f08f0d3"
}

variable "key_pair_name" {
  type        = string
  description = "Name of the key pair for instance authentication"
  default     = "3-tier-key-pair"
}

variable "multi_az_deployment" {
  type        = bool
  description = "Enable multi-AZ deployment for RDS"
  default     = false
}

variable "database_username" {
  type        = string
  description = "Username for the RDS database"
  sensitive   = true
}

variable "database_password" {
  type        = string
  description = "Password for the RDS database"
  sensitive   = true
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "main-vpc" }
}

resource "aws_subnet" "public" {
  count                   = length(var.web_subnet_cidrs)
  cidr_block              = element(var.web_subnet_cidrs, count.index)
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  tags                    = { Name = "public-subnet-${count.index}" }
}

resource "aws_subnet" "private_app" {
  count             = length(var.app_subnet_cidrs)
  cidr_block        = element(var.app_subnet_cidrs, count.index)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags              = { Name = "private-app-subnet-${count.index}" }
}

resource "aws_subnet" "private_db" {
  count             = length(var.db_subnet_cidrs)
  cidr_block        = element(var.db_subnet_cidrs, count.index)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags              = { Name = "private-db-subnet-${count.index}" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

resource "aws_eip" "nat" {
  vpc  = true
  tags = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[1].id
  tags          = { Name = "main-nat-gateway" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "public-route-table" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = { Name = "private-route-table" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  count          = length(aws_subnet.private_app)
  subnet_id      = element(aws_subnet.private_app[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db" {
  count          = length(aws_subnet.private_db)
  subnet_id      = element(aws_subnet.private_db[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "alb_sg" {
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
  tags = { Name = "alb-sg" }
}

resource "aws_security_group" "web_server_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.name]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.name]
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
  tags = { Name = "web-server-sg" }
}

resource "aws_security_group" "ssh_bastion_sg" {
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
  tags = { Name = "ssh-bastion-sg" }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server_sg.name]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "db-sg" }
}

resource "aws_instance" "web" {
  count           = 2
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_pair_name
  subnet_id       = element(aws_subnet.public[*].id, count.index)
  security_groups = [aws_security_group.web_server_sg.name]
  user_data       = filebase64("install-apache.sh")
  tags = {
    Name = "web-instance-${count.index}"
  }
}

resource "aws_instance" "app" {
  count           = 2
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_pair_name
  subnet_id       = element(aws_subnet.private_app[*].id, count.index)
  security_groups = [aws_security_group.web_server_sg.name]
  tags = {
    Name = "app-instance-${count.index}"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main-dbsubgroup"
  subnet_ids = aws_subnet.private_db[*].id
  tags       = { Name = "main-dbsubgroup" }
}

resource "aws_db_instance" "mysql" {
  identifier           = "main-mysql"
  engine               = "mysql"
  engine_version       = "8.0.39"
  instance_class       = var.multi_az_deployment ? "db.t3.medium" : "db.t3.micro"
  allocated_storage    = 10
  username             = var.database_username
  password             = var.database_password
  parameter_group_name = "default.mysql8.0"
  subnet_group_name    = aws_db_subnet_group.main.name
  security_group_names = [aws_security_group.db_sg.name]
  skip_final_snapshot  = true
  availability_zone    = "us-east-1b"
  multi_az             = var.multi_az_deployment
  tags                 = { Name = "main-mysql" }
}

output "load_balancer_dns_name" {
  value = aws_lb.main.dns_name
}
