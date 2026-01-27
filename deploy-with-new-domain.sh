#!/bin/bash

# Deploy Website with New Domain (ffjconsultingllc.com)

BUCKET_NAME="ffj-consulting-website"
PROFILE="my-sso"
REGION="us-east-1"

echo "============================================================"
echo "Deploying Website to S3"
echo "============================================================"
echo "Bucket: $BUCKET_NAME"
echo "Profile: $PROFILE"
echo "============================================================"
echo ""

# Step 1: Build frontend
echo "Step 1: Building frontend..."
cd frontend
npm run build
if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi
echo "✅ Build successful"
echo ""

# Step 2: Deploy to S3 with correct content types
echo "Step 2: Deploying to S3 with correct MIME types..."
cd ..

# Upload all files first
aws s3 sync frontend/dist/ s3://$BUCKET_NAME \
    --delete \
    --profile $PROFILE \
    --region $REGION

# Fix content-type for JavaScript files (must be application/javascript for ES modules)
echo "Fixing JavaScript file content-type..."
JS_FILE=$(find frontend/dist/assets -name "*.js" | head -1)
if [ -n "$JS_FILE" ]; then
    JS_KEY=$(echo $JS_FILE | sed 's|frontend/dist/||')
    aws s3api copy-object \
        --bucket $BUCKET_NAME \
        --copy-source "${BUCKET_NAME}/${JS_KEY}" \
        --key "$JS_KEY" \
        --content-type "application/javascript" \
        --metadata-directive REPLACE \
        --profile $PROFILE \
        --region $REGION
    echo "✅ Fixed content-type for JavaScript files"
fi

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Deployment failed"
    exit 1
fi

echo "✅ Files uploaded to S3"
echo ""

# Step 3: Invalidate CloudFront cache
echo "Step 3: Invalidating CloudFront cache..."
CLOUDFRONT_DIST_ID="E3545N3N8YO2FZ"
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_DIST_ID \
    --paths "/*" \
    --profile $PROFILE \
    --query 'Invalidation.Id' \
    --output text 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$INVALIDATION_ID" ]; then
    echo "✅ CloudFront cache invalidation created: $INVALIDATION_ID"
    echo "   Cache invalidation takes 1-5 minutes to complete"
else
    echo "⚠️  Could not create cache invalidation automatically"
    echo "   Please create it manually in AWS Console:"
    echo "   https://console.aws.amazon.com/cloudfront/home#/distributions/$CLOUDFRONT_DIST_ID/invalidations"
fi

echo ""
echo "============================================================"
echo "Deployment Complete"
echo "============================================================"
echo ""
echo "Your website is now deployed with the new domain:"
echo "  https://ffjconsultingllc.com"
echo "  https://www.ffjconsultingllc.com"
echo ""
echo "⚠️  Next Steps:"
echo "  1. Wait 1-5 minutes for cache invalidation"
echo "  2. Hard refresh your browser (Cmd+Shift+R)"
echo "  3. Test the URLs above"
echo ""
echo "Check CloudFront status:"
echo "  https://console.aws.amazon.com/cloudfront/home"
echo "============================================================"
