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

# Data block to get VPC ID
data "aws_vpcs" "my_vpcs" {
  tags = {
    Name = "my-vpc"
  }
}

# Create a security group for the EC2 instance
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  # SSH rule
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP rule
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS rule
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-security-group"
  }
}

# Create an AWS Key Pair
resource "aws_key_pair" "my_aws_key_pair" {
  key_name   = "my-key-pair"  # Specify the desired key pair name
  public_key = "temporary-placeholder"  # Placeholder value for AWS to generate the key pair
}

# Output the public key to a local file
resource "local_file" "aws_key_pair_public_key" {
  filename = "C:\\Users\\Hi\\Downloads\\aws_key_pair_public_key.pub"  # Specify the desired local file path
  content  = aws_key_pair.my_aws_key_pair.public_key
}

# Data block to get the fingerprint of the AWS Key Pair
data "aws_key_pair" "my_aws_key_pair_data" {
  key_name = aws_key_pair.my_aws_key_pair.key_name
}

# Output the fingerprint to a local file
resource "local_file" "aws_key_pair_fingerprint" {
  filename = "C:\\Users\\Hi\\Downloads\\aws_key_pair_fingerprint.txt"  # Specify the desired local file path
  content  = data.aws_key_pair.my_aws_key_pair_data.fingerprint
}

# Manually generate the private key using ssh-keygen or other tools
# Once generated, you can use it in your local environment
# Example command: ssh-keygen -f my-key-pair



# Create an EC2 instance within the VPC
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0cd59ecaf368e5ccf"  # Replace with your desired AMI ID
  instance_type = "t2.micro"

  subnet_id     = aws_subnet.my_subnet.id
  key_name      = aws_key_pair.my_aws_key_pair.key_name  # Use the name of the AWS key pair
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  tags = {
    Name = "my-ec2-instance"
  }
}
