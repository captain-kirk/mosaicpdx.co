# MosaicPDX

This project is a React application designed to host a family website for Mosaic PDX. 

## Features

Sign up for the email list

## Deployment Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd mosaic.com
   ```

3. Bootstrap the backend 
   ```
   cd infra/bootstrap
   terraform init
   terraform plan
   terraform apply
   ```

4. Install dependencies:
   ```
   npm install
   ```

5. Build Next.js application
   ```
   npm run build 
   ```

6. Deploy
   ```
   ./infra/bin/deploy.sh <env> 
   ```
