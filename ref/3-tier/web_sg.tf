resource "aws_security_group" "webserver-security-group" {
  name        = "Web Server Security Group"
  description = "Allow HTTP/HTTPS from ALB and SSH from anywhere"
  vpc_id      = aws_vpc.vpc_test.id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-security-group.id]
  #   cidr_blocks = [
  #   aws_subnet.public-webtier-subnet-1.cidr_block,
  #   aws_subnet.public-webtier-subnet-2.cidr_block
  # ]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Allow HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-security-group.id]
  }

  ingress {
    description = "Allow SSH from anywhere"
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
    Name = "Web Server Security Group"
  }
}
