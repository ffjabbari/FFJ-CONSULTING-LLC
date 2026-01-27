#!/bin/bash

# Check deployment status

BUCKET_NAME="ffj-consulting-website"
PROFILE="my-sso"
REGION="us-east-1"

echo "============================================================"
echo "Checking Deployment Status"
echo "============================================================"
echo ""

# Check if JS file exists in S3
echo "Checking if JavaScript file exists in S3..."
JS_FILE=$(aws s3 ls s3://$BUCKET_NAME/assets/ --profile $PROFILE --region $REGION | grep "\.js$" | head -1 | awk '{print $4}')

if [ -n "$JS_FILE" ]; then
    echo "✅ Found JS file: $JS_FILE"
    echo ""
    echo "Checking file details..."
    aws s3api head-object \
        --bucket $BUCKET_NAME \
        --key "assets/$JS_FILE" \
        --profile $PROFILE \
        --region $REGION \
        --query '{ContentType:ContentType,LastModified:LastModified}' \
        --output json
else
    echo "❌ No JavaScript files found in S3!"
fi

echo ""
echo "Listing all files in S3 bucket:"
aws s3 ls s3://$BUCKET_NAME/ --recursive --profile $PROFILE --region $REGION | head -20

echo ""
echo "============================================================"
echo "CloudFront Cache Invalidation Status"
echo "============================================================"
aws cloudfront list-invalidations \
    --distribution-id E3545N3N8YO2FZ \
    --profile $PROFILE \
    --max-items 1 \
    --query 'InvalidationList.Items[0].{Id:Id,Status:Status,CreateTime:CreateTime}' \
    --output json

echo ""
echo "============================================================"
