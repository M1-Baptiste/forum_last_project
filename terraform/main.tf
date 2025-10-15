# Définition du fournisseur AWS et de la région
provider "aws" {
  region = var.aws_region
}

# Création d'un groupe de sécurité pour autoriser le trafic entrant
resource "aws_security_group" "forum_sg" {
  name        = "forum-security-group"
  description = "Allow inbound traffic for the forum services"

  # Règle pour le port SSH (22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle pour le port Thread (81)
  ingress {
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle pour le port Sender (8090)
  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# Création de l'instance EC2
resource "aws_instance" "forum_app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.aws_key_pair
  vpc_security_group_ids = [aws_security_group.forum_sg.id]

  # Script de démarrage pour l'installation de Docker et le déploiement
  user_data = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
    sudo usermod -aG docker ubuntu

    # Création du fichier docker-compose
    cat << EOF > /home/ubuntu/docker-compose.yml
version: '3.8'

services:
  # Service 1: API - Gestion des messages du forum
  api:
    image: ghcr.io/${var.github_repository}/api:${var.app_version}
    container_name: forum-api
    restart: always
    depends_on:
      - db
    networks:
      - backend
    environment:
      - DATABASE_URL=mongodb://db:27017/forum

  # Service 2: Base de données MongoDB
  db:
    image: mongo:latest
    container_name: forum-db
    restart: always
    networks:
      - backend
    volumes:
      - db-data:/data/db

  # Service 3: Thread - Affichage des messages (port 80)
  thread:
    image: ghcr.io/${var.github_repository}/thread:${var.app_version}
    container_name: forum-thread
    restart: always
    ports:
      - "81:80"
    depends_on:
      - api
    networks:
      - frontend

  # Service 4: Sender - Écriture des messages (port 8090)
  sender:
    image: ghcr.io/${var.github_repository}/sender:${var.app_version}
    container_name: forum-sender
    restart: always
    ports:
      - "8090:8080"
    depends_on:
      - api
    networks:
      - frontend

networks:
  backend:
    internal: true
  frontend:
    driver: bridge

volumes:
  db-data:
  api-data:
EOF

    # Lancement des services
    cd /home/ubuntu
    docker-compose up -d
  EOT

  tags = {
    Name    = "forum-app"
    Project = "DevSecOps-Forum"
  }
}

# Stockage de l'adresse IP publique de l'instance
resource "aws_eip" "forum_ip" {
  instance = aws_instance.forum_app.id
}