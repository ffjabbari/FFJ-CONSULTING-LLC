# AWS Deployment Guide

This guide explains how to deploy the FFJ Consulting LLC website to AWS.

## Architecture Overview

The deployment will use:
- **Frontend**: AWS S3 + CloudFront (React static site)
- **Backend**: AWS Elastic Beanstalk or EC2 (C# ASP.NET Core API)
- **Database**: RDS or keep SQLite (depending on requirements)
- **Domain**: Route 53 (optional)

## Prerequisites

1. AWS Account with appropriate permissions
2. AWS CLI installed and configured
3. .NET SDK installed (for backend)
4. Node.js installed (for frontend build)

## Deployment Steps

### Step 1: Build Frontend

```bash
cd frontend
npm install
npm run build
```

This creates a `dist/` folder with static files.

### Step 2: Deploy Frontend to S3

```bash
# Create S3 bucket
aws s3 mb s3://ffj-consulting-website --region us-east-1

# Upload build files
aws s3 sync dist/ s3://ffj-consulting-website --delete

# Enable static website hosting
aws s3 website s3://ffj-consulting-website \
  --index-document index.html \
  --error-document index.html
```

### Step 3: Configure CloudFront (Optional but Recommended)

```bash
# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name ffj-consulting-website.s3.amazonaws.com
```

### Step 4: Deploy Backend

**Option A: Elastic Beanstalk (Recommended)**

```bash
cd backend/FFJConsulting.API
dotnet publish -c Release

# Create deployment package
zip -r deploy.zip . -x "*.git*" "*.vs*"

# Deploy to Elastic Beanstalk
eb init
eb create ffj-consulting-api
eb deploy
```

**Option B: EC2**

1. Launch EC2 instance (Ubuntu/Amazon Linux)
2. Install .NET SDK
3. Deploy application
4. Configure security groups for port 5000

### Step 5: Update CORS Settings

Update backend `Program.cs` to allow your CloudFront domain:

```csharp
policy.WithOrigins("https://your-cloudfront-domain.cloudfront.net")
```

### Step 6: Update Frontend API Endpoint

Update `vite.config.js` or create environment variables for production API URL.

## Automated Deployment Script

A deployment script will be created to automate these steps.

## Deployment via Cursor

Simply tell Cursor:
```
Deploy the site to AWS
```

Cursor will:
1. Build the frontend
2. Deploy to S3/CloudFront
3. Deploy backend to Elastic Beanstalk/EC2
4. Configure CORS and API endpoints
5. Provide deployment URLs

## Environment Configuration

Create `.env.production`:
```
VITE_API_URL=https://your-api-domain.com
```

## Post-Deployment

1. Test the deployed site
2. Verify API connectivity
3. Check CloudFront cache settings
4. Monitor CloudWatch logs
5. Set up SSL certificates (via ACM)

## Cost Estimation

- S3: ~$0.023/GB storage + $0.005/1000 requests
- CloudFront: ~$0.085/GB data transfer
- Elastic Beanstalk: Free tier available, then ~$29/month
- EC2: t2.micro free tier, then ~$10-50/month

## Security Considerations

1. Enable S3 bucket versioning
2. Configure CloudFront with SSL
3. Set up WAF rules
4. Enable CloudWatch monitoring
5. Configure IAM roles properly

## Troubleshooting

- **CORS errors**: Check backend CORS configuration
- **404 errors**: Configure S3/CloudFront for SPA routing
- **API not reachable**: Check security groups and IAM roles
- **Build failures**: Verify Node.js and .NET SDK versions
