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

resource "aws_instance" "cap-server" {
  ami           = "ami-005e54dee72cc1d00" # us-west-2
  instance_type = "t2.micro"

  user_data = <<-EOF
                #!/usr/bin/env bash
                echo "Hello, World" > index.html
                nonhup busybox httpd -f -p 8080 &
                EOF

  tags = {
    Name = "cap_on"
  }

}

resource "aws_security_group" "instance" {
  name = "cap-server-group"

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}