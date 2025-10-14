output "public_ip" {
  value = aws_instance.forum_app.public_ip
}

output "sender_url" {
  value = "http://${aws_instance.forum_app.public_ip}:8090"
}

output "thread_url" {
  value = "http://${aws_instance.forum_app.public_ip}:81"
}