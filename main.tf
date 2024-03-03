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

resource "aws_key_pair" "example_key_pair" {
  key_name   = "example-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")  # Update with the path to your public key
}

resource "aws_instance" "exam_instance" {
  ami           = "ami-07d9b9ddc6cd8dd30"  # Update with your desired AMI ID
  instance_type = "t2.micro"

  key_name = aws_key_pair.example_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.example_sg.id]
  subnet_id              = aws_subnet.example_subnet.id

  tags = {
    Name = "exam-instance"
  }
}

output "public_ip" {
  value = aws_instance.exam_instance.public_ip
}
