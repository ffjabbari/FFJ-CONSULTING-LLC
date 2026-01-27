#!/bin/bash

# Simple Certificate Validation Diagnostic
# Checks everything to ensure setup is correct

PROFILE="my-sso"
REGION="us-east-1"
DOMAIN_NAME="ffjconsulting.com"
HOSTED_ZONE_ID="Z0268429M8AW2ZUY4ECU"
CERT_ARN="arn:aws:acm:us-east-1:678113404782:certificate/9ca7d55a-41cf-4441-87e0-0b5b739d6164"

echo "============================================================"
echo "Certificate Validation Diagnostic"
echo "============================================================"
echo ""

ERRORS=0

# Test 1: Certificate exists
echo "✓ Test 1: Certificate Accessibility"
CERT_STATUS=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'Certificate.Status' \
    --output text 2>&1)

if [ $? -eq 0 ] && [ "$CERT_STATUS" != "" ]; then
    echo "  ✅ Certificate accessible - Status: $CERT_STATUS"
else
    echo "  ❌ Cannot access certificate"
    ((ERRORS++))
fi
echo ""

# Test 2: Get validation records from certificate
echo "✓ Test 2: Validation Records from Certificate"
CERT_JSON=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --output json 2>&1)

# Extract validation records properly
RECORD1_NAME=$(echo "$CERT_JSON" | jq -r '.Certificate.DomainValidationOptions[0].ResourceRecord.Name // empty')
RECORD1_VALUE=$(echo "$CERT_JSON" | jq -r '.Certificate.DomainValidationOptions[0].ResourceRecord.Value // empty')
RECORD2_NAME=$(echo "$CERT_JSON" | jq -r '.Certificate.DomainValidationOptions[1].ResourceRecord.Name // empty')
RECORD2_VALUE=$(echo "$CERT_JSON" | jq -r '.Certificate.DomainValidationOptions[1].ResourceRecord.Value // empty')

if [ -n "$RECORD1_NAME" ] && [ "$RECORD1_NAME" != "null" ]; then
    echo "  ✅ Record 1: $RECORD1_NAME"
    echo "     Value: $RECORD1_VALUE"
else
    echo "  ❌ Record 1 not found"
    ((ERRORS++))
fi

if [ -n "$RECORD2_NAME" ] && [ "$RECORD2_NAME" != "null" ]; then
    echo "  ✅ Record 2: $RECORD2_NAME"
    echo "     Value: $RECORD2_VALUE"
else
    echo "  ❌ Record 2 not found"
    ((ERRORS++))
fi
echo ""

# Test 3: Check if records exist in Route 53
echo "✓ Test 3: Validation Records in Route 53"
if [ -n "$RECORD1_NAME" ] && [ "$RECORD1_NAME" != "null" ]; then
    R53_RECORD1=$(aws route53 list-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --profile "$PROFILE" \
        --query "ResourceRecordSets[?Name=='$RECORD1_NAME']" \
        --output json 2>&1)
    
    if echo "$R53_RECORD1" | jq -e '. | length > 0' > /dev/null 2>&1; then
        R53_VALUE1=$(echo "$R53_RECORD1" | jq -r '.[0].ResourceRecords[0].Value // empty')
        echo "  ✅ Record 1 exists in Route 53"
        if [ "$R53_VALUE1" == "$RECORD1_VALUE" ]; then
            echo "     ✅ Value matches certificate"
        else
            echo "     ❌ Value mismatch!"
            echo "        Expected: $RECORD1_VALUE"
            echo "        Found:    $R53_VALUE1"
            ((ERRORS++))
        fi
    else
        echo "  ❌ Record 1 missing in Route 53"
        ((ERRORS++))
    fi
fi

if [ -n "$RECORD2_NAME" ] && [ "$RECORD2_NAME" != "null" ]; then
    R53_RECORD2=$(aws route53 list-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --profile "$PROFILE" \
        --query "ResourceRecordSets[?Name=='$RECORD2_NAME']" \
        --output json 2>&1)
    
    if echo "$R53_RECORD2" | jq -e '. | length > 0' > /dev/null 2>&1; then
        R53_VALUE2=$(echo "$R53_RECORD2" | jq -r '.[0].ResourceRecords[0].Value // empty')
        echo "  ✅ Record 2 exists in Route 53"
        if [ "$R53_VALUE2" == "$RECORD2_VALUE" ]; then
            echo "     ✅ Value matches certificate"
        else
            echo "     ❌ Value mismatch!"
            echo "        Expected: $RECORD2_VALUE"
            echo "        Found:    $R53_VALUE2"
            ((ERRORS++))
        fi
    else
        echo "  ❌ Record 2 missing in Route 53"
        ((ERRORS++))
    fi
fi
echo ""

# Test 4: Certificate domains
echo "✓ Test 4: Certificate Domains"
CERT_DOMAIN1=$(echo "$CERT_JSON" | jq -r '.Certificate.DomainValidationOptions[0].DomainName // empty')
CERT_DOMAIN2=$(echo "$CERT_JSON" | jq -r '.Certificate.DomainValidationOptions[1].DomainName // empty')

if [ "$CERT_DOMAIN1" == "$DOMAIN_NAME" ]; then
    echo "  ✅ Domain 1 matches: $CERT_DOMAIN1"
else
    echo "  ❌ Domain 1 mismatch: expected $DOMAIN_NAME, got $CERT_DOMAIN1"
    ((ERRORS++))
fi

if [ "$CERT_DOMAIN2" == "www.$DOMAIN_NAME" ]; then
    echo "  ✅ Domain 2 matches: $CERT_DOMAIN2"
else
    echo "  ❌ Domain 2 mismatch: expected www.$DOMAIN_NAME, got $CERT_DOMAIN2"
    ((ERRORS++))
fi
echo ""

# Summary
echo "============================================================"
echo "Summary"
echo "============================================================"
echo "Errors found: $ERRORS"
echo "Certificate Status: $CERT_STATUS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅ ALL CHECKS PASSED!"
    echo ""
    if [ "$CERT_STATUS" == "PENDING_VALIDATION" ]; then
        echo "Your certificate setup is CORRECT."
        echo ""
        echo "The certificate is pending validation, which is normal."
        echo "AWS is verifying the DNS records - this typically takes:"
        echo "  • 5-15 minutes (most common)"
        echo "  • Up to 30 minutes (occasionally)"
        echo "  • Rarely up to 1 hour"
        echo ""
        echo "Everything is configured correctly - just wait for AWS."
        echo ""
        echo "Check again in 10-15 minutes:"
        echo "  ./check-cert-and-continue.sh"
    elif [ "$CERT_STATUS" == "ISSUED" ]; then
        echo "✅ Certificate is validated and ready!"
        echo ""
        echo "Run: ./continue-cloudfront-setup.sh"
    else
        echo "Certificate status: $CERT_STATUS"
    fi
else
    echo "❌ Found $ERRORS error(s)"
    echo "Please review the errors above and fix them."
fi
echo "============================================================"
