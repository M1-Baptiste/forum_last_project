# Définition du fournisseur AWS et de la région
provider "aws" {
  region = var.aws_region
}

# Crée un groupe de sécurité pour autoriser le trafic entrant
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

  # Règle pour les ports des services (API, Thread, Sender)
  ingress {
    from_port   = 80
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle pour la communication inter-conteneurs (via self=true) et inter-instances si nécessaire
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

# Crée une seule instance EC2 pour tous les services
resource "aws_instance" "forum_all_services" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.forum_sg.name]
  key_name      = var.aws_key_pair

  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io docker-compose
    sudo usermod -aG docker ubuntu

    # Création du fichier docker-compose.yml
    cat <<'EOF' > /home/ubuntu/docker-compose.yml
version: '3.8'
services:
  api:
    image: ghcr.io/${var.github_repository}/api:${var.app_version}
    container_name: forum-api
    ports:
      - "8080:3000"
    restart: always

  db:
    image: mongo:latest
    container_name: forum-db
    restart: always
    # Laisser la base de données interne au réseau Docker pour des raisons de sécurité
    # Si d'autres services ont besoin d'y accéder, ils peuvent le faire via le nom de service 'db'

  thread:
    image: ghcr.io/${var.github_repository}/thread:${var.app_version}
    container_name: forum-thread
    ports:
      - "81:80"
    restart: always

  sender:
    image: ghcr.io/${var.github_repository}/sender:${var.app_version}
    container_name: forum-sender
    ports:
      - "8090:8080"
    restart: always
EOF

    # Exécution des services avec Docker Compose
    sudo docker-compose -f /home/ubuntu/docker-compose.yml up -d
  EOT

  tags = {
    Name = "forum-services-instance-baptiste"
  }
}