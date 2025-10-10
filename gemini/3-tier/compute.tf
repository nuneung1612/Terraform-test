# Data source for user data script
data "local_file" "install_apache" {
  filename = "${path.module}/install-apache.sh"
}

# Key Pair
resource "aws_key_pair" "main" {
  key_name   = var.key_pair_name
  # This expects a public key file to exist.
  # For a fully automated setup, you might generate the key with tls_private_key
  # and store the private key in a secure location like AWS Secrets Manager.
  # For this example, we assume the key is pre-generated and the public key is provided.
  # You need to create '3-tier-key-pair.pub' or similar and provide its path.
  # Example: public_key = file("~/.ssh/id_rsa.pub")
  # For this template to be runnable, we will comment this out.
  # You must create the key in the AWS console or via CLI with the name var.key_pair_name
  public_key = file("C:/Users/USER/Downloads/3-tier-key-pair.ppk")
  
  tags = {
    Name = var.key_pair_name
  }
}

# Web Tier EC2 Instances
resource "aws_instance" "web" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.web_instance_type
  key_name      = aws_key_pair.main.key_name

  # Place instances across the two public subnets
  subnet_id = count.index == 0 ? aws_subnet.public_1.id : aws_subnet.public_2.id

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = data.local_file.install_apache.content

  tags = {
    Name = "${var.project_name}-web-instance-${count.index + 1}"
    Tier = "Web"
  }
}

# App Tier EC2 Instances
resource "aws_instance" "app" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.app_instance_type
  key_name      = aws_key_pair.main.key_name

  # Place instances across the two private app subnets
  subnet_id = count.index == 0 ? aws_subnet.app_1.id : aws_subnet.app_2.id

  vpc_security_group_ids = [aws_security_group.web_sg.id] # Reusing web SG for now

  tags = {
    Name = "${var.project_name}-app-instance-${count.index + 1}"
    Tier = "App"
  }
}
