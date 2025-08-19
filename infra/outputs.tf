# Outputs
output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.email-list.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.email-list.arn
}

output "submit_email_function_name" {
  description = "Name of the submit email Lambda function"
  value       = aws_lambda_function.submit_email.function_name
}

output "get_emails_function_name" {
  description = "Name of the get emails Lambda function"
  value       = aws_lambda_function.get_emails.function_name
}

output "certificate_arn" {
  value       = aws_acm_certificate.main.arn
  description = "ARN of the ACM certificate"
}

output "hosted_zone_id" {
  value       = data.aws_route53_zone.main.zone_id
  description = "Route53 hosted zone ID"
}

# CloudFront outputs
output "cloudfront_url" {
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
  description = "CloudFront distribution URL"
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.website.id
  description = "CloudFront distribution ID"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.website.domain_name
  description = "CloudFront distribution domain name"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.website.bucket
  description = "Name of the S3 bucket for the website"
}

output "website_url" {
  value       = "https://${var.domain_name}"
  description = "URL of the website"
}

output "api_invoke_url" {
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.us-east-1.amazonaws.com/${var.environment}"
  description = "Invoke URL for the API Gateway"
}
