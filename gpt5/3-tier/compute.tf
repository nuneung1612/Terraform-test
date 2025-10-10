// compute.tf
resource "aws_instance" "web" {
  for_each                    = aws_subnet.public
  ami                         = var.ami_id
  instance_type               = var.web_instance_type
  subnet_id                   = each.value.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  user_data                   = file("${path.module}/install-apache.sh")

  tags = merge(var.tags, { Name = "web-${each.value.availability_zone}" })
}

resource "aws_instance" "app" {
  for_each               = aws_subnet.app
  ami                    = var.ami_id
  instance_type          = var.app_instance_type
  subnet_id              = each.value.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name

  tags = merge(var.tags, { Name = "app-${each.value.availability_zone}" })
}
