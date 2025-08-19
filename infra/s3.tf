# S3 bucket for static website hosting

# Random suffix for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# S3 bucket for website
resource "aws_s3_bucket" "website" {
  bucket = "mosaicpdx-website"
  
  tags = local.common_tags
}

# Block public access (CloudFront will access via OAC)
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = false  # Allow CloudFront access
  ignore_public_acls      = true
  restrict_public_buckets = false  # Allow CloudFront access
}

# Ensure objects are private by default
resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 bucket policy to allow CloudFront access via OAC
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_cloudfront_distribution.website]
}

# Ensure the bucket is configured for website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# Data source for current AWS region
data "aws_region" "current" {}

# S3 outputs
output "website_bucket_name" {
  value       = aws_s3_bucket.website.id
  description = "S3 bucket name for website"
}

output "website_bucket_arn" {
  value       = aws_s3_bucket.website.arn
  description = "S3 bucket ARN"
}