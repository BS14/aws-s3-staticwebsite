output "website_domain" {
    description = "Domain of the website endpoint."
    value = aws_s3_bucket_website_configuration.s3_bucket.website_domain
}

output "website_endpoint" {
    description = "Website endpoint."
    value = aws_s3_bucket_website_configuration.s3_bucket.website_endpoint
  
}