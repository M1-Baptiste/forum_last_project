variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

variable "github_repository" {
  type    = string
  description = "Le nom de votre dépôt GitHub (ex: votre-utilisateur/votre-repo)"
}

variable "app_version" {
  type    = string
  description = "Le tag de l'image Docker (hash du commit)"
}