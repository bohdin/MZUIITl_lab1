provider "aws" {
  region     = "eu-north-1"                   # Регіон AWS
  access_key = var.aws_access_key            # Ключ доступу AWS (з variables.tf)
  secret_key = var.aws_secret_key            # Секретний ключ AWS (з variables.tf)
}

# Створення Security Group для доступу через HTTP та SSH
resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH traffic"

  # Дозвіл на вхідний HTTP-трафік
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Дозвіл на вхідний SSH-трафік
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Дозвіл на весь вихідний трафік
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Створення EC2 інстансу
resource "aws_instance" "web_server" {
  ami           = "ami-0c1ac8a41498c1a9c"    # Ubuntu 22.04 LTS
  instance_type = "t3.micro"                 # Тип інстансу (Free Tier)
  key_name      = "keyforlab1"   # Наприклад: "keyforlab4"
  security_groups = [aws_security_group.web_sg.name]

  # User Data для встановлення Docker
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              EOF

  tags = {
    Name = "Terraform-Web-Server"
  }
}

# Вивід публічного IP інстансу
output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}