terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "capsg" {
  name = "cap-server-group"

  ingress {
    from_port        = var.server_port
    to_port          = var.server_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cap-server" {
  ami           = "ami-005e54dee72cc1d00" # us-west-2
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.capsg.id]

  user_data = <<-EOF
                #!/usr/bin/env bash
                echo "Hello, World" > index.html
                nonhup busybox httpd -f -p ${var.server_port} &
                EOF

  tags = {
    Name = "cap_on"
  }

}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

output "public_ip" {
  value = aws_instance.cap-server.public_ip
  description = "The public IP address of the architecture"
}
