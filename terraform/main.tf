# Définition du fournisseur AWS et de la région
provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${path.module}/deployer-key.pem"
  file_permission = "0600"
}

# Création d'un groupe de sécurité pour autoriser le trafic entrant
resource "aws_security_group" "forum_sg" {
  name_prefix = "forum-security-group-baptiste"
  description = "Allow inbound traffic for the forum services"

  # Règle pour le port SSH (22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle pour les ports des services
  ingress {
    from_port   = 8080
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle pour la communication inter-instances
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  # Règle pour le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Récupération de l'AMI (Amazon Machine Image) la plus récente pour Ubuntu
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

# Création de l'instance EC2 pour l'API
resource "aws_instance" "forum_api" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.forum_sg.name]
  key_name        = aws_key_pair.deployer.key_name

  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
    sudo usermod -aG docker ubuntu
    docker pull ghcr.io/${var.github_repository}/api:${var.app_version}
    docker run -d --name forum-api -p 3000:3000 ghcr.io/${var.github_repository}/api:${var.app_version}
  EOT

  tags = {
    Name = "forum-api-instance-baptiste"
  }
}

# Création de l'instance EC2 pour la base de données
resource "aws_instance" "forum_db" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.forum_sg.name]
  key_name        = aws_key_pair.deployer.key_name


  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io
    sudo docker run -d --name forum-db mongo:latest
  EOT

  tags = {
    Name = "forum-db-instance-baptiste"
  }
}

# Création de l'instance EC2 pour le service Thread
resource "aws_instance" "forum_thread" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.forum_sg.name]
  key_name        = aws_key_pair.deployer.key_name


  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
    sudo usermod -aG docker ubuntu
    docker pull ghcr.io/${var.github_repository}/thread:${var.app_version}
    docker run -d --name forum-thread -p 81:80 ghcr.io/${var.github_repository}/thread:${var.app_version}
  EOT

  tags = {
    Name = "forum-thread-instance-baptiste"
  }
}

# Création de l'instance EC2 pour le service Sender
resource "aws_instance" "forum_sender" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.forum_sg.name]
  key_name        = aws_key_pair.deployer.key_name

  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
    sudo usermod -aG docker ubuntu
    docker pull ghcr.io/${var.github_repository}/sender:${var.app_version}
    docker run -d --name forum-sender -p 8090:8080 ghcr.io/${var.github_repository}/sender:${var.app_version}
  EOT

  tags = {
    Name = "forum-sender-instance-baptiste"
  }
}