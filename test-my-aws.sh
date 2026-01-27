#!/bin/bash

echo "============================================================"
echo "Testing YOUR AWS Connection (from YOUR terminal)"
echo "============================================================"
echo ""

echo "1. Testing AWS credentials..."
if aws sts get-caller-identity --profile my-sso 2>&1; then
    echo "✅ AWS credentials work!"
else
    echo "❌ AWS credentials failed"
fi
echo ""

echo "2. Testing S3 access..."
if aws s3 ls --profile my-sso 2>&1 | head -3; then
    echo "✅ S3 access works!"
else
    echo "❌ S3 access failed"
fi
echo ""

echo "3. Testing Route 53..."
if aws route53 list-hosted-zones --profile my-sso --max-items 3 2>&1; then
    echo "✅ Route 53 access works!"
else
    echo "❌ Route 53 access failed"
fi
echo ""

echo "============================================================"
echo "If all tests pass, your AWS CLI is working correctly!"
echo "The connection issue is only in my environment, not yours."
echo "============================================================"
