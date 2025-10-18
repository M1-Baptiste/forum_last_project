output "db_private_ip" {
  value       = aws_instance.db.private_ip
  description = "Private IP of the database instance"
}

output "api_public_ip" {
  value       = aws_instance.api.public_ip
  description = "Public IP of the API instance"
}

output "thread_public_ip" {
  value       = aws_instance.thread.public_ip
  description = "Public IP of the Thread instance"
}

output "sender_public_ip" {
  value       = aws_instance.sender.public_ip
  description = "Public IP of the Sender instance"
}

output "thread_url" {
  value       = "http://${aws_instance.thread.public_ip}"
  description = "URL to access Thread service"
}

output "sender_url" {
  value       = "http://${aws_instance.sender.public_ip}"
  description = "URL to access Sender service"
}