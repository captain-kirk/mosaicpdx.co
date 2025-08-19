#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment is provided
if [ -z "$1" ]; then
    print_error "Environment not specified. Usage: ./deploy.sh [dev|staging|prod]"
    exit 1
fi

ENVIRONMENT=$1

print_status "🚀 Deploying Mosaic website - Environment: $ENVIRONMENT"

# Navigate to infrastructure directory
cd "$(dirname "$0")/.."

print_status "📦 Zipping Lambda function folders..."
mkdir -p lambda-packages
for dir in lambda/*/ ; do
  fname=$(basename "$dir")
  zip -r "lambda-packages/${fname}.zip" "$dir" > /dev/null
done

# Deploy infrastructure
print_status "🏗️  Deploying infrastructure..."
terraform init
terraform apply -var="environment=$ENVIRONMENT" -auto-approve

# Get all outputs from Terraform
print_status "🔍 Fetching infrastructure outputs..."
API_URL=$(terraform output -raw api_invoke_url || echo "")
S3_BUCKET=$(terraform output -raw s3_bucket_name || echo "")
CLOUDFRONT_DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id || echo "")
WEBSITE_URL=$(terraform output -raw website_url || echo "")

# Validate that all required outputs were found
if [ -z "$API_URL" ] || [ -z "$S3_BUCKET" ] || [ -z "$CLOUDFRONT_DISTRIBUTION_ID" ] || [ -z "$WEBSITE_URL" ]; then
  print_error "One or more required Terraform outputs are missing. Check your infra/outputs.tf file."
  exit 1
fi

# Update .env.local for the Next.js build
print_status "🔧 Updating .env.local with API URL: $API_URL"
cat > ../.env.local <<EOF
NEXT_PUBLIC_AWS_API_GATEWAY_URL=${API_URL}
EOF

# Build the Next.js application
print_status "🏗️  Building Next.js application..."
cd .. # Move to project root
npm run build
cd infra # Return to infra directory

# Upload website files to S3
print_status "📤 Uploading website files to S3..."
aws s3 sync ../out/ s3://$S3_BUCKET --delete

# Invalidate CloudFront cache
print_status "🔄 Invalidating CloudFront cache..."
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"

print_status "✅ Deployment successful!"
echo
print_status "📋 Deployment Summary:"
echo "  Environment: $ENVIRONMENT"
echo "  Website URL: $WEBSITE_URL"
echo "  S3 Bucket: $S3_BUCKET"
echo "  CloudFront Distribution: $CLOUDFRONT_DISTRIBUTION_ID"