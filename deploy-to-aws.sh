#!/bin/bash

# AWS Deployment Script for FFJ Consulting LLC
# Uses AWS profile: my-sso (hardcoded below)

set -e

echo "=========================================="
echo "FFJ Consulting LLC - AWS Deployment"
echo "Profile: my-sso"
echo "=========================================="
echo ""

# Configuration
S3_BUCKET_NAME="ffj-consulting-website"
AWS_REGION="us-east-1"
BACKEND_APP_NAME="ffj-consulting-api"
# AWS profile (hardcoded so deploy works every time; edit here to change)
AWS_PROFILE="my-sso"
AWS_CMD="aws --profile ${AWS_PROFILE}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    echo "Install from: https://aws.amazon.com/cli/"
    exit 1
fi

if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}❌ .NET SDK is not installed${NC}"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Step 1: Build Frontend
echo "Step 1: Building frontend..."
cd frontend

if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

npm run build

if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Build failed - dist folder not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Frontend built successfully${NC}"
echo ""

# Step 2: Create S3 Bucket (if it doesn't exist)
echo "Step 2: Setting up S3 bucket..."
cd ..

if $AWS_CMD s3 ls "s3://${S3_BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating S3 bucket..."
    $AWS_CMD s3 mb "s3://${S3_BUCKET_NAME}" --region "${AWS_REGION}"
    echo -e "${GREEN}✅ S3 bucket created${NC}"
else
    echo -e "${YELLOW}⚠️  S3 bucket already exists${NC}"
fi

# Step 3: Upload Frontend to S3
echo "Step 3: Uploading frontend to S3..."
if ! $AWS_CMD s3 sync frontend/dist/ "s3://${S3_BUCKET_NAME}" --delete --region "${AWS_REGION}"; then
    echo -e "${RED}❌ S3 upload failed (often AccessDenied).${NC}"
    echo "  Check: (1) AWS identity: aws sts get-caller-identity"
    echo "  (2) Bucket owner: $AWS_CMD s3api get-bucket-acl --bucket ${S3_BUCKET_NAME}"
    echo "  (3) Edit AWS_PROFILE at the top of this script if you use a different profile."
    exit 1
fi

# Enable static website hosting
$AWS_CMD s3 website "s3://${S3_BUCKET_NAME}" \
    --index-document index.html \
    --error-document index.html \
    --region "${AWS_REGION}"

# Set bucket policy for public read access
cat > /tmp/bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${S3_BUCKET_NAME}/*"
    }
  ]
}
EOF

$AWS_CMD s3api put-bucket-policy \
    --bucket "${S3_BUCKET_NAME}" \
    --policy file:///tmp/bucket-policy.json \
    --region "${AWS_REGION}"

echo -e "${GREEN}✅ Frontend uploaded to S3${NC}"
echo ""

# Step 4: Build Backend
echo "Step 4: Building backend..."
cd backend/FFJConsulting.API

dotnet restore
dotnet publish -c Release -o ./publish

echo -e "${GREEN}✅ Backend built successfully${NC}"
echo ""

# Step 5: Deploy Backend (Elastic Beanstalk)
echo "Step 5: Deploying backend to Elastic Beanstalk..."
echo -e "${YELLOW}Note: This requires EB CLI. Install with: pip install awsebcli${NC}"
echo ""

if command -v eb &> /dev/null; then
    if [ ! -f ".elasticbeanstalk/config.yml" ]; then
        echo "Initializing Elastic Beanstalk..."
        eb init -p "docker" "${BACKEND_APP_NAME}" --region "${AWS_REGION}"
    fi
    
    echo "Creating/updating Elastic Beanstalk environment..."
    eb deploy
    echo -e "${GREEN}✅ Backend deployed to Elastic Beanstalk${NC}"
else
    echo -e "${YELLOW}⚠️  EB CLI not found. Skipping backend deployment.${NC}"
    echo "To deploy backend manually:"
    echo "  1. Install EB CLI: pip install awsebcli"
    echo "  2. Run: cd backend/FFJConsulting.API && eb init && eb create && eb deploy"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Deployment Complete!${NC}"
echo "=========================================="
echo ""
echo "Frontend URL: http://${S3_BUCKET_NAME}.s3-website-${AWS_REGION}.amazonaws.com"
echo ""
echo "Next steps:"
echo "  1. Set up CloudFront distribution for better performance"
echo "  2. Configure custom domain (optional)"
echo "  3. Set up SSL certificate via ACM"
echo "  4. Update CORS settings in backend for CloudFront domain"
echo ""
