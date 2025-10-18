# === IPs ===
output "db_private_ip" {
  value       = aws_instance.db.private_ip
  description = "Private IP of the database instance"
}

output "db_public_ip" {
  value       = aws_instance.db.public_ip
  description = "Public IP of the database instance"
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

# === URLs des services ===
output "api_url" {
  value       = "http://${aws_instance.api.public_ip}:3000"
  description = "URL to access API service"
}

output "thread_url" {
  value       = "http://${aws_instance.thread.public_ip}:80"
  description = "URL to access Thread service"
}

output "sender_url" {
  value       = "http://${aws_instance.sender.public_ip}:80"
  description = "URL to access Sender service"
}

output "db_connection_string" {
  value       = "mongodb://${aws_instance.db.private_ip}:27017"
  description = "MongoDB connection string (private IP)"
}

# === Commandes SSH ===
output "ssh_db" {
  value       = "ssh -i ~/.ssh/${var.aws_key_pair}.pem ubuntu@${aws_instance.db.public_ip}"
  description = "SSH command to connect to DB instance"
}

output "ssh_api" {
  value       = "ssh -i ~/.ssh/${var.aws_key_pair}.pem ubuntu@${aws_instance.api.public_ip}"
  description = "SSH command to connect to API instance"
}

output "ssh_thread" {
  value       = "ssh -i ~/.ssh/${var.aws_key_pair}.pem ubuntu@${aws_instance.thread.public_ip}"
  description = "SSH command to connect to Thread instance"
}

output "ssh_sender" {
  value       = "ssh -i ~/.ssh/${var.aws_key_pair}.pem ubuntu@${aws_instance.sender.public_ip}"
  description = "SSH command to connect to Sender instance"
}