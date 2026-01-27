#!/bin/bash

echo "Testing AWS Connection with profile: my-sso"
echo "============================================"
echo ""

echo "1. Testing AWS credentials..."
aws sts get-caller-identity --profile my-sso
echo ""

echo "2. Testing S3 access..."
aws s3 ls --profile my-sso | head -3
echo ""

echo "3. Testing Route 53 access..."
aws route53 list-hosted-zones --profile my-sso --max-items 5
echo ""

echo "4. Testing Route 53 Domains access..."
aws route53domains list-domains --region us-east-1 --profile my-sso 2>&1 | head -10
echo ""

echo "============================================"
echo "If all commands work, AWS connection is fine!"
echo "If you see errors, share them and we'll fix them."
