resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_instance" "docker" {
  ami           = local.ami_id
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.main.id   # 👈 attach to subnet created by Terraform
  vpc_security_group_ids = [aws_security_group.allow_all_docker.id]
   associate_public_ip_address = true 

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = file("docker.sh")

  tags = {
     Name = "${var.project}-${var.environment}-docker"
  }
}

resource "aws_security_group" "allow_all_docker" {
    name        = "allow_all_docker"
    description = "allow all traffic"
    vpc_id      = aws_vpc.main.id

    ingress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    lifecycle {
      create_before_destroy = true
    }

    tags = {
        Name = "allow-all-docker"
    }
}