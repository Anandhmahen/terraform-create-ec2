provider "aws" {
    region = "ap-south-1"
  }

resource "aws_instance" "example_ec2" {
    #  ubuntu 20.04
    ami = "ami-024c319d5d14b463e"
    instance_type = "t3a.micro"
    availability_zone = "ap-south-1a"
    key_name = aws_key_pair.example-key-pair.key_name
    vpc_security_group_ids = [aws_security_group.example-security-group.id]
    associate_public_ip_address = true
    tags = {
      "Name" = "Example EC2"
    }
    lifecycle {
      ignore_changes = [ami]
    }
    depends_on = [
      aws_key_pair.example-key-pair
    ]
 }

# create new key pair value
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "example-key-pair" {
  key_name   = "example-key"
  public_key = tls_private_key.pk.public_key_openssh

# Create a "example-key.pem" in your terraform directory
  provisioner "local-exec" { 
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./example-key.pem"
  }
}

# creating security group for instance
resource "aws_security_group" "example-security-group" {
  name = "example-sg"
  description = "Allow HTTP and SSH traffic via Terraform"

  # allowing inbound - port 22 for ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allowing outbound - all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
