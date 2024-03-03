# main.tf

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Replace with your desired availability zone in us-east-1
  map_public_ip_on_launch = false

  tags = {
    Name = "my-subnet"
  }
}

# Create an internet gateway for the VPC
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Generate SSH Key Pair
resource "tls_private_key" "my_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Output the public key for external use
output "public_key" {
  value = tls_private_key.my_key_pair.public_key_openssh
}

# Create an EC2 instance within the VPC
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  
  instance_type = "t2.micro"

  subnet_id     = aws_subnet.my_subnet.id
  key_name      = tls_private_key.my_key_pair.id  
  security_group = ["your_security_group_id"]

  tags = {
    Name = "my-ec2-instance"
  }
}
