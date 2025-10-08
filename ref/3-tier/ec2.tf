
# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "owner-alias"
#     values = ["amazon"]
#   }

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
# }
# data "aws_ami" "selected" {
#   # If you prefer to resolve dynamically by filters, adjust this data source.
#   # Here we stick to explicit AMI id for determinism, but validate it exists.
#   most_recent = true
#   owners      = ["self", "amazon", "aws-marketplace"]

#   filter {
#     name   = "image-id"
#     values = [var.ami_id]
#   }
# }

resource "aws_instance" "public-web-template-1" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-webtier-subnet-1.id
  vpc_security_group_ids = [aws_security_group.webserver-security-group.id]
  key_name               = var.key_name
  user_data              = file("install-apache.sh")

  tags = {
    Name = "webtier-instance-1"
  }
}

resource "aws_instance" "public-web-template-2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-webtier-subnet-2.id
  vpc_security_group_ids = [aws_security_group.webserver-security-group.id]
  key_name               = var.key_name
  user_data              = file("install-apache.sh")

  tags = {
    Name = "webtier-instance-2"
  }
}

resource "aws_instance" "private-app-template-1" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private-apptier-subnet-1.id
  vpc_security_group_ids = [aws_security_group.ssh-security-group.id]
  key_name               = var.key_name

  tags = {
    Name = "apptier-instance"
  }
}

resource "aws_instance" "private-app-template-2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private-apptier-subnet-2.id
  vpc_security_group_ids = [aws_security_group.ssh-security-group.id]
  key_name               = var.key_name

  tags = {
    Name = "apptier-instance"
  }
}





