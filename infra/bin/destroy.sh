#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
    print_error "Environment not specified. Usage: ./destroy.sh [dev|staging|prod]"
    exit 1
fi

ENVIRONMENT=$1

print_warning "🗑️  Destroying Mosaic Email Collection System - Environment: $ENVIRONMENT"
print_warning "This will permanently delete all resources and data!"

# Navigate to infrastructure directory
cd "$(dirname "$0")"

# Confirm destruction
read -p "Are you sure you want to destroy the $ENVIRONMENT environment? This cannot be undone! (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Destruction cancelled."
    exit 1
fi

# Double confirmation for production
if [ "$ENVIRONMENT" = "prod" ]; then
    read -p "You are about to destroy the PRODUCTION environment. Type 'DELETE PRODUCTION' to confirm: " confirm
    if [ "$confirm" != "DELETE PRODUCTION" ]; then
        print_status "Destruction cancelled."
        exit 1
    fi
fi

# Destroy the infrastructure
print_status "🗑️  Destroying Terraform infrastructure..."
terraform destroy -var="environment=$ENVIRONMENT" -auto-approve

print_status "✅ Infrastructure destroyed successfully!"
print_warning "All data has been permanently deleted."
