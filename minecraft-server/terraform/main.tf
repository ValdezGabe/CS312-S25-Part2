provider "aws" {
  region = var.aws_region
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "minecraft" {
  name        = "${var.server_name}-sg"
  description = "Minecraft Server Security Group"
  
  ingress {
    description = "Minecraft Port"
    from_port   = var.minecraft_port
    to_port     = var.minecraft_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.server_name}-security-group"
  }
}

resource "aws_instance" "minecraft" {
  ami             = "ami-03c983f9003cb9cd1"  # Ubuntu 22.04 LTS in us-west-2
  instance_type   = var.instance_type
  security_groups = [aws_security_group.minecraft.name]
  
  user_data = templatefile("${path.module}/user_data.sh", {
    minecraft_port = var.minecraft_port
  })
  
  tags = {
    Name = var.server_name
  }
}