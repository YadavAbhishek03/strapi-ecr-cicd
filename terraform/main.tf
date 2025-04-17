provider "aws" {
  region = "us-east-1"
}

# Key pair

resource "aws_key_pair" "deployer" {
  key_name   = "strapi-key"
  public_key = file("/home/surya/devops-terraform-project/terraform/ssh-key/strapi-key.pub")
}

# Default VPC

data "aws_vpc" "default" {
  default = true
}

# Security Group

resource "aws_security_group" "strapi_sg_v4" {
  name        = "strapi-sg-v4"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
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
    Name = "strapi-sg-v"
  }
}

# Instance

resource "aws_instance" "strapi" {
  ami                         = "ami-084568db4383264d4" # Ubuntu
  instance_type               = "t2.medium" # Free-tier eligible
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.strapi_sg_v4.id]
  associate_public_ip_address = true

user_data = file("/home/surya/devops-terraform-project/terraform/user_data.sh")

  tags = {
    Name = "StrapiInstance0"
  }
}
