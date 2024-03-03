resource "aws_instance" "instance_name" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example_subnet.id  # Assuming a subnet resource named example_subnet exists
  vpc_security_group_ids = [
    aws_security_group.example_sg.id  # Assuming a security group resource named example_sg exists
  ]
  key_name = aws_key_pair.id_rsa.key_name  # Assuming a key pair resource named id_rsa exists

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("C:\\Users\\Hi\\id_rsa")  # Double backslashes in the file path
    timeout     = "4m"
  }

  tags = {
    Name = "test_server"
  }
}

// Sends your public key to the instance
resource "aws_key_pair" "id_rsa" {
  key_name   = "id_rsa"
  public_key = file("/Users/var.user/.ssh/id_rsa.pub")

  tags = {
    Name = "test_server"
  }
}
