#!/bin/bash

# Check SSL Certificate Validation Status with Details

PROFILE="my-sso"
REGION="us-east-1"
CERT_ARN="arn:aws:acm:us-east-1:678113404782:certificate/9ca7d55a-41cf-4441-87e0-0b5b739d6164"
HOSTED_ZONE_ID="Z0268429M8AW2ZUY4ECU"

echo "============================================================"
echo "SSL Certificate Validation Status Check"
echo "============================================================"
echo ""

# Get certificate details
CERT_INFO=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Error getting certificate info:"
    echo "$CERT_INFO"
    exit 1
fi

CERT_STATUS=$(echo "$CERT_INFO" | jq -r '.Certificate.Status')
CERT_DOMAIN=$(echo "$CERT_INFO" | jq -r '.Certificate.DomainName')

echo "Certificate: $CERT_DOMAIN"
echo "Status: $CERT_STATUS"
echo ""

if [ "$CERT_STATUS" = "ISSUED" ]; then
    echo "✅ Certificate is VALIDATED and ready to use!"
    echo ""
    echo "You can now run: ./continue-cloudfront-setup.sh"
elif [ "$CERT_STATUS" = "PENDING_VALIDATION" ]; then
    echo "⏳ Certificate is still being validated..."
    echo ""
    echo "This typically takes 5-30 minutes after DNS records are added."
    echo ""
    echo "Checking DNS validation records in Route 53..."
    
    # Check if validation records exist
    VALIDATION_RECORDS=$(echo "$CERT_INFO" | jq -r '.Certificate.DomainValidationOptions[] | select(.ResourceRecord != null) | .ResourceRecord')
    
    if [ -n "$VALIDATION_RECORDS" ]; then
        echo ""
        echo "Expected validation records:"
        echo "$VALIDATION_RECORDS" | jq -r '. | "Name: \(.Name), Value: \(.Value)"'
        echo ""
        
        # Check if records exist in Route 53
        RECORD1_NAME=$(echo "$VALIDATION_RECORDS" | jq -r '.[0].Name // empty' | sed 's/\.$//')
        if [ -n "$RECORD1_NAME" ]; then
            echo "Checking if validation records exist in Route 53..."
            R53_RECORDS=$(aws route53 list-resource-record-sets \
                --hosted-zone-id "$HOSTED_ZONE_ID" \
                --profile "$PROFILE" \
                2>&1 | jq -r ".ResourceRecordSets[] | select(.Name | contains(\"$RECORD1_NAME\")) | .Name")
            
            if [ -n "$R53_RECORDS" ]; then
                echo "✅ Validation records found in Route 53"
            else
                echo "⚠️  Validation records may not be in Route 53 yet"
                echo "   Run: ./add-cert-validation-records.sh"
            fi
        fi
    fi
    
    echo ""
    echo "What to check:"
    echo "1. DNS records were added to Route 53 (run ./add-cert-validation-records.sh if not)"
    echo "2. DNS propagation (can take a few minutes)"
    echo "3. AWS needs to verify the records (5-30 minutes)"
    echo ""
    echo "Run this script again in a few minutes:"
    echo "  ./check-cert-status.sh"
    echo ""
    echo "Or run the auto-continue script:"
    echo "  ./check-cert-and-continue.sh"
    
elif [ "$CERT_STATUS" = "VALIDATION_TIMED_OUT" ]; then
    echo "❌ Certificate validation timed out"
    echo ""
    echo "Possible issues:"
    echo "1. DNS records not correctly added to Route 53"
    echo "2. DNS propagation issues"
    echo "3. Domain not properly configured"
    echo ""
    echo "Try running: ./add-cert-validation-records.sh again"
    
elif [ "$CERT_STATUS" = "FAILED" ]; then
    echo "❌ Certificate validation failed"
    echo ""
    echo "Check the certificate in AWS Console for error details:"
    echo "https://console.aws.amazon.com/acm/home?region=us-east-1#/certificates"
    
else
    echo "Certificate status: $CERT_STATUS"
fi

echo ""
echo "============================================================"
