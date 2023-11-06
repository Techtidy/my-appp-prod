# Define the provider and region
provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Specify your existing VPC ID
variable "existing_vpc_id" {
  default = "vpc-08d04c9a4a6db7601"  # Replace with your VPC ID
}

# Create a subnet within the existing VPC
resource "aws_subnet" "my_subnet" {
  vpc_id            = var.existing_vpc_id
  cidr_block        = "10.0.1.0/24"  # Replace with your desired CIDR block
  availability_zone = "us-east-1a"
}

# Create a security group for the EC2 instance
resource "aws_security_group" "my_security_group" {
  name_prefix = "my-ec2-sg"

  # Define inbound rules to allow SSH (port 22) and HTTP (port 80) traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Define an outbound rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-0fc5d935ebf8bc3bc"  # Replace with your desired AMI ID
  instance_type = "t2.micro"               # Replace with your desired instance type
  subnet_id     = aws_subnet.my_subnet.id
  key_name      = "hello"             # Replace with your SSH key pair
  security_groups = [aws_security_group.my_security_group.name]

  user_data = <<-EOF
              #!/bin/bash
              yum -y update
              yum -y install httpd
              service httpd start
              yum -y install git
              git clone https://github.com/your/repo.git /var/www/html
              chmod -R 755 /var/www/html
              service httpd restart
              EOF
}

# Output the public IP of the EC2 instance (optional)
output "public_ip" {
  value = aws_instance.my_ec2.public_ip
}
