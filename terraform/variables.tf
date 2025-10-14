variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "aws_key_pair" {
  type    = string
  default = "my-key-pair"
}

variable "github_repository" {
  type    = string
  description = "Le nom de votre dépôt GitHub (ex: votre-utilisateur/votre-repo)"
}

variable "app_version" {
  type    = string
  description = "Le tag de l'image Docker (hash du commit)"
}