provider "aws" {
  region = "us-east-1"  # Update with your desired AWS region
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example_subnet" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"  # Update with your desired availability zone

  map_public_ip_on_launch = true

  tags = {
    Name = "example-subnet"
  }
}

resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Allow SSH inbound traffic"

  vpc_id = aws_vpc.example_vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "examp_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_instance" "examp_instance" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example_subnet.id  # Replace with your subnet resource
  vpc_security_group_ids = [aws_security_group.example_sg.id]  # Replace with your security group resource
  key_name      = tls_private_key.example_key_pair.public_key_openssh

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.exam_key_pair.private_key_pem
    timeout     = "4m"
  }

  tags = {
    Name = "exam-instance"
  }
}

output "private_key" {
  value = tls_private_key.exam_key_pair.private_key_pem
}

output "public_key" {
  value = tls_private_key.exam_key_pair.public_key_openssh
}
