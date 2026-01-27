#!/bin/bash

# Fix CloudFront Cache Issue
# This script redeploys files and invalidates CloudFront cache

BUCKET_NAME="ffj-consulting-website"
PROFILE="my-sso"
REGION="us-east-1"
CLOUDFRONT_DIST_ID="E3545N3N8YO2FZ"

echo "============================================================"
echo "Fixing CloudFront Cache Issue"
echo "============================================================"
echo "Bucket: $BUCKET_NAME"
echo "CloudFront Distribution: $CLOUDFRONT_DIST_ID"
echo "Profile: $PROFILE"
echo "============================================================"
echo ""

# Step 1: Rebuild frontend
echo "Step 1: Rebuilding frontend..."
cd frontend
npm run build
if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi
echo "✅ Build successful"
echo ""

# Step 2: Deploy to S3
echo "Step 2: Deploying to S3..."
cd ..
aws s3 sync frontend/dist/ s3://$BUCKET_NAME --delete --profile $PROFILE --region $REGION

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ S3 sync failed. Check your AWS connection:"
    echo "   1. Make sure you're connected to the internet/VPN"
    echo "   2. Try: aws sso login --profile $PROFILE"
    echo "   3. Or check your AWS credentials"
    exit 1
fi

echo "✅ Files uploaded to S3"
echo ""

# Step 3: Invalidate CloudFront cache
echo "Step 3: Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_DIST_ID \
    --paths "/*" \
    --profile $PROFILE \
    --query 'Invalidation.Id' \
    --output text)

if [ $? -eq 0 ]; then
    echo "✅ CloudFront cache invalidation created: $INVALIDATION_ID"
    echo ""
    echo "⚠️  Note: Cache invalidation takes 1-5 minutes to complete"
    echo "   Your website should update shortly at:"
    echo "   https://ffjconsultingllc.com"
else
    echo "❌ Failed to create cache invalidation"
    echo "   You can create it manually in AWS Console:"
    echo "   https://console.aws.amazon.com/cloudfront/home"
    exit 1
fi

echo ""
echo "============================================================"
echo "Deployment Complete!"
echo "============================================================"
echo ""
echo "Next steps:"
echo "1. Wait 1-5 minutes for cache invalidation"
echo "2. Hard refresh your browser (Cmd+Shift+R or Ctrl+Shift+R)"
echo "3. Test: https://ffjconsultingllc.com"
echo "============================================================"
