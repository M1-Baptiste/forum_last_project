variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

variable "aws_key_pair" {
  type    = string
  default = "wNgF0hClJNdkVD7rIvPZApxviudIt/0tZZvQ4tjB"
}

variable "github_repository" {
  type    = string
  description = "Le nom de votre dépôt GitHub (ex: votre-utilisateur/votre-repo)"
}

variable "app_version" {
  type    = string
  description = "Le tag de l'image Docker (hash du commit)"
}