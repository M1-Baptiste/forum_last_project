output "services_public_ip" {
  value = aws_instance.forum_all_services.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.aws_key_pair}.pem ubuntu@${aws_instance.forum_all_services.public_ip}"
}