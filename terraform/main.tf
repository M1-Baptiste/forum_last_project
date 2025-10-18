# Définition du fournisseur AWS et de la région
provider "aws" {
  region = var.aws_region
}

# Groupe de sécurité pour l'API
resource "aws_security_group" "api_sg" {
  name_prefix = "forum-api-sg-baptiste-"
  description = "Security group for API service"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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
    Name = "forum-api-sg-baptiste"
  }
}

# Groupe de sécurité pour la DB
resource "aws_security_group" "db_sg" {
  name_prefix = "forum-db-sg-baptiste-"
  description = "Security group for Database"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
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
    Name = "forum-db-sg-baptiste"
  }
}

# Groupe de sécurité pour Thread
resource "aws_security_group" "thread_sg" {
  name_prefix = "forum-thread-sg-baptiste-"
  description = "Security group for Thread service"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "forum-thread-sg-baptiste"
  }
}

# Groupe de sécurité pour Sender
resource "aws_security_group" "sender_sg" {
  name_prefix = "forum-sender-sg-baptiste-"
  description = "Security group for Sender service"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "forum-sender-sg-baptiste"
  }
}

# Récupère l'AMI la plus récente pour Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Instance EC2 pour la base de données
resource "aws_instance" "db" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.db_sg.name]
  key_name        = var.aws_key_pair

  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io
    sudo usermod -aG docker ubuntu
    sudo systemctl enable docker
    sudo systemctl start docker

    # Démarrage du conteneur MongoDB
    sudo docker run -d \
      --name forum-db \
      --restart always \
      -p 27017:27017 \
      mongo:latest
  EOT

  tags = {
    Name = "forum-db-baptiste"
  }
}

# Instance EC2 pour l'API
resource "aws_instance" "api" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.api_sg.name]
  key_name        = var.aws_key_pair

  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io
    sudo usermod -aG docker ubuntu
    sudo systemctl enable docker
    sudo systemctl start docker

    # Attendre que Docker soit prêt
    sleep 10

    # Démarrage du conteneur API
    sudo docker run -d \
      --name forum-api \
      --restart always \
      -p 3000:3000 \
      -e DB_HOST=${aws_instance.db.private_ip} \
      ghcr.io/${lower(var.github_repository)}/api:${var.app_version}
  EOT

  depends_on = [aws_instance.db]

  tags = {
    Name = "forum-api-baptiste"
  }
}

# Instance EC2 pour Thread
resource "aws_instance" "thread" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.thread_sg.name]
  key_name        = var.aws_key_pair

  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io
    sudo usermod -aG docker ubuntu
    sudo systemctl enable docker
    sudo systemctl start docker

    # Attendre que Docker soit prêt
    sleep 10

    # Démarrage du conteneur Thread
    sudo docker run -d \
      --name forum-thread \
      --restart always \
      -p 80:80 \
      -e API_URL=http://${aws_instance.api.public_ip}:3000 \
      ghcr.io/${lower(var.github_repository)}/api:${var.app_version}
  EOT

  depends_on = [aws_instance.api]

  tags = {
    Name = "forum-thread-baptiste"
  }
}

# Instance EC2 pour Sender
resource "aws_instance" "sender" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.sender_sg.name]
  key_name        = var.aws_key_pair

  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io
    sudo usermod -aG docker ubuntu
    sudo systemctl enable docker
    sudo systemctl start docker

    # Attendre que Docker soit prêt
    sleep 10

    # Démarrage du conteneur Sender
    sudo docker run -d \
      --name forum-sender \
      --restart always \
      -p 80:80 \
      -e API_URL=http://${aws_instance.api.public_ip}:3000 \
      ghcr.io/${lower(var.github_repository)}/api:${var.app_version}
  EOT

  depends_on = [aws_instance.api]

  tags = {
    Name = "forum-sender-baptiste"
  }
}