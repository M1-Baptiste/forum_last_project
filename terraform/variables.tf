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
  default = "baptiste_key"
}

variable "github_repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
}

variable "app_version" {
  type    = string
  description = "Le tag de l'image Docker (hash du commit)"
}