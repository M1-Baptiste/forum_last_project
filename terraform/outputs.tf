output "api_public_ip" {
  value = aws_instance.forum_api.public_ip
}

output "db_public_ip" {
  value = aws_instance.forum_db.public_ip
}

output "thread_public_ip" {
  value = aws_instance.forum_thread.public_ip
}

output "sender_public_ip" {
  value = aws_instance.forum_sender.public_ip
}

output "ssh_command" {
  value = "ssh -i my-forum-key.pem ubuntu@${aws_instance.forum_api.public_ip}"
}