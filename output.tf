output "websiteendpoint" {
    value=aws_s3_bucket.vijaybucket.website_endpoint
  
}

output "ec2ami" {
    value = aws_instance.nginxserver
  
}

output "ec2ami2" {
    value = aws_instance.terraforminstance
  
}

