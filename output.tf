# Output for the S3 Website Endpoint
output "website_endpoint" {
  value       = aws_s3_bucket.vijaybucket.website_endpoint
}

# Output for the Nginx Server EC2 Instance ID
output "nginx_ec2_instance_id" {
  value       = aws_instance.nginxserver.id
}

# Output for the Static Web Hosting EC2 Instance ID
output "static_web_ec2_instance_id" {
  value       = aws_instance.terraforminstance.id
}

# Output for the Nginx Server Public IP
output "nginx_server_public_ip" {
  value       = aws_instance.nginxserver.public_ip
}

# Output for the Static Web Hosting Public IP
output "static_web_public_ip" {
  value       = aws_instance.terraforminstance.public_ip
}
