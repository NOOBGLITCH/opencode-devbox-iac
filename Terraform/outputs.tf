output "ec2_public_ip" {
  description = "Public IP of OpenChamber devbox"
  value       = aws_instance.devbox.public_ip
}

output "devbox_domain" {
  description = "Pre-configured sslip.io HTTPS domain"
  value       = "https://${replace(aws_instance.devbox.public_ip, ".", "-")}.sslip.io"
}

output "iam_user_name" {
  description = "IAM user name"
  value       = aws_iam_user.dev_user.name
}

output "iam_access_key_id" {
  description = "IAM access key id"
  value       = aws_iam_access_key.dev_user_key.id
}

output "iam_secret_key" {
  description = "IAM secret access key"
  value       = aws_iam_access_key.dev_user_key.secret
  sensitive   = true
}
