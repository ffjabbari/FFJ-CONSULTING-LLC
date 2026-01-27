#!/bin/bash

# Fix JavaScript content-type in S3

BUCKET_NAME="ffj-consulting-website"
PROFILE="my-sso"
REGION="us-east-1"

echo "Fixing JavaScript file content-type..."

# Find the JS file in S3
JS_FILE=$(aws s3 ls s3://$BUCKET_NAME/assets/ --profile $PROFILE --region $REGION | grep "\.js$" | awk '{print $4}' | head -1)

if [ -z "$JS_FILE" ]; then
    echo "❌ No JavaScript file found in S3"
    exit 1
fi

echo "Found JS file: $JS_FILE"
echo "Updating content-type to application/javascript..."

# Update content-type using copy-object
aws s3api copy-object \
    --bucket $BUCKET_NAME \
    --copy-source "${BUCKET_NAME}/assets/${JS_FILE}" \
    --key "assets/${JS_FILE}" \
    --content-type "application/javascript" \
    --metadata-directive REPLACE \
    --profile $PROFILE \
    --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ Content-type updated successfully"
    echo ""
    echo "Invalidating CloudFront cache..."
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --distribution-id E3545N3N8YO2FZ \
        --paths "/assets/*" \
        --profile $PROFILE \
        --query 'Invalidation.Id' \
        --output text)
    
    if [ $? -eq 0 ]; then
        echo "✅ Cache invalidation created: $INVALIDATION_ID"
        echo "   Wait 1-2 minutes, then hard refresh your browser"
    fi
else
    echo "❌ Failed to update content-type"
    exit 1
fi
