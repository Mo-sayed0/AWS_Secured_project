#!/bin/bash
# Update the system packages
sudo yum update -y

# Install Apache HTTP Server
sudo yum install -y httpd

sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello from App Server</h1><p>Health check endpoint</p>" > /var/www/html/health
