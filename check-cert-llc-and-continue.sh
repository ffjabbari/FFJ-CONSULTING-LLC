#!/bin/bash

# Check Certificate Status and Continue with CloudFront Setup

PROFILE="my-sso"
REGION="us-east-1"
CERT_ARN="arn:aws:acm:us-east-1:678113404782:certificate/a8e8b60c-ccfe-4ee2-b86f-2520d1d24d7e"

echo "Checking certificate status..."
CERT_STATUS=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'Certificate.Status' \
    --output text 2>&1)

echo "Certificate status: $CERT_STATUS"
echo ""

if [ "$CERT_STATUS" = "ISSUED" ]; then
    echo "✅ Certificate is validated! Proceeding with CloudFront setup..."
    echo ""
    ./create-cloudfront-ffjconsultingllc.sh
else
    echo "⏳ Certificate is still being validated (status: $CERT_STATUS)"
    echo "   Please wait a few more minutes and run this script again:"
    echo "   ./check-cert-llc-and-continue.sh"
    echo ""
    echo "Since the domain was registered via Route 53, validation should be faster"
    echo "   (typically 5-15 minutes instead of 30+ minutes)"
fi
