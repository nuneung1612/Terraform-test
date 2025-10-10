resource "aws_key_pair" "main" {
  key_name   = var.key_pair_name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web_server" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name               = aws_key_pair.main.key_name
  user_data              = file("install-apache.sh")
  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

resource "aws_instance" "app_server" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_app[count.index].id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name               = aws_key_pair.main.key_name
  tags = {
    Name = "app-server-${count.index + 1}"
  }
}
