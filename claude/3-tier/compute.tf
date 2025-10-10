# compute.tf
resource "aws_instance" "web" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.web_instance_type
  subnet_id              = aws_subnet.public[count.index].id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = file("${path.module}/install-apache.sh")

  tags = {
    Name = "web-server-${count.index + 1}"
    Tier = "Web"
  }
}

resource "aws_instance" "app" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.app_instance_type
  subnet_id              = aws_subnet.app[count.index].id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "app-server-${count.index + 1}"
    Tier = "Application"
  }
}