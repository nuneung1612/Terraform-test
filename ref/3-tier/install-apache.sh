#!/bin/bash

sudo yum update -y
sudo yum install -y httpd

# Enable and start Apache
sudo systemctl enable httpd
sudo systemctl start httpd

# Create a simple index.html
echo "<html><body><h1>Welcome to my web server!</h1></body></html>" | sudo tee /var/www/html/index.html > /dev/null
