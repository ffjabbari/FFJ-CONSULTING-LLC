#!/bin/bash

# Check certificate status and continue with CloudFront setup if ready

PROFILE="my-sso"
REGION="us-east-1"
CERT_ARN="arn:aws:acm:us-east-1:678113404782:certificate/9ca7d55a-41cf-4441-87e0-0b5b739d6164"

echo "Checking certificate status..."
CERT_STATUS=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'Certificate.Status' \
    --output text 2>/dev/null)

echo "Certificate status: $CERT_STATUS"
echo ""

if [ "$CERT_STATUS" = "ISSUED" ]; then
    echo "✅ Certificate is validated! Proceeding with CloudFront setup..."
    echo ""
    ./continue-cloudfront-setup.sh
else
    echo "⏳ Certificate is still being validated (status: $CERT_STATUS)"
    echo "   Please wait a few more minutes and run this script again:"
    echo "   ./check-cert-and-continue.sh"
    echo ""
    echo "Or check status manually:"
    echo "aws acm describe-certificate --certificate-arn $CERT_ARN --region $REGION --profile $PROFILE | jq -r '.Certificate.Status'"
fi
