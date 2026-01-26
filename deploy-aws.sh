#!/bin/bash

# AWS Deployment Script for FFJ Consulting LLC
# Uses the my-sso AWS profile

set -e

echo "=========================================="
echo "FFJ Consulting LLC - AWS Deployment"
echo "Using profile: my-sso"
echo "=========================================="
echo ""

# Configuration
S3_BUCKET_NAME="ffj-consulting-website"
AWS_REGION="us-east-1"
AWS_PROFILE="my-sso"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    exit 1
fi

# Verify AWS credentials
echo "Verifying AWS credentials..."
if ! aws sts get-caller-identity --profile $AWS_PROFILE &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to AWS. Check your credentials and network.${NC}"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
echo -e "${GREEN}✅ Connected to AWS Account: $ACCOUNT_ID${NC}"
echo ""

# Step 1: Build Frontend
echo "Step 1: Building frontend..."
cd frontend

if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
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

if aws s3 ls "s3://${S3_BUCKET_NAME}" --profile $AWS_PROFILE 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating S3 bucket: ${S3_BUCKET_NAME}..."
    aws s3 mb "s3://${S3_BUCKET_NAME}" --region "${AWS_REGION}" --profile $AWS_PROFILE
    echo -e "${GREEN}✅ S3 bucket created${NC}"
else
    echo -e "${YELLOW}⚠️  S3 bucket already exists${NC}"
fi

# Step 3: Upload Frontend to S3
echo "Step 3: Uploading frontend to S3..."
aws s3 sync frontend/dist/ "s3://${S3_BUCKET_NAME}" --delete --region "${AWS_REGION}" --profile $AWS_PROFILE

echo -e "${GREEN}✅ Files uploaded to S3${NC}"

# Step 4: Enable static website hosting
echo "Step 4: Configuring static website hosting..."
aws s3 website "s3://${S3_BUCKET_NAME}" \
    --index-document index.html \
    --error-document index.html \
    --region "${AWS_REGION}" \
    --profile $AWS_PROFILE

# Step 5: Disable Block Public Access (must be done before setting policy)
echo "Step 5: Configuring public access settings..."
aws s3api put-public-access-block \
    --bucket "${S3_BUCKET_NAME}" \
    --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false" \
    --region "${AWS_REGION}" \
    --profile $AWS_PROFILE

echo -e "${GREEN}✅ Public access block disabled${NC}"

# Step 6: Set bucket policy for public read access
echo "Step 6: Setting bucket policy for public access..."
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

aws s3api put-bucket-policy \
    --bucket "${S3_BUCKET_NAME}" \
    --policy file:///tmp/bucket-policy.json \
    --region "${AWS_REGION}" \
    --profile $AWS_PROFILE

echo -e "${GREEN}✅ Bucket configured for public access${NC}"
echo ""

# Get website URL
WEBSITE_URL="http://${S3_BUCKET_NAME}.s3-website-${AWS_REGION}.amazonaws.com"

echo "=========================================="
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo "=========================================="
echo ""
echo "Your website is now live at:"
echo -e "${GREEN}${WEBSITE_URL}${NC}"
echo ""
echo "Next steps:"
echo "1. Visit the URL above to verify your site is working"
echo "2. Share this URL with me so I can update all links"
echo "3. (Optional) Set up CloudFront for HTTPS"
echo "4. (Optional) Configure custom domain"
echo ""
