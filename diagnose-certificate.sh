#!/bin/bash

# Comprehensive Certificate Validation Diagnostic
# This checks everything to ensure the setup is correct

set -e

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
WARNINGS=0

# Test 1: Certificate exists and is accessible
echo "Test 1: Certificate Accessibility"
CERT_INFO=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    2>&1)

if [ $? -eq 0 ]; then
    echo "✅ Certificate is accessible"
    CERT_STATUS=$(echo "$CERT_INFO" | jq -r '.Certificate.Status')
    CERT_DOMAIN=$(echo "$CERT_INFO" | jq -r '.Certificate.DomainName')
    CERT_TYPE=$(echo "$CERT_INFO" | jq -r '.Certificate.Type')
    VALIDATION_METHOD=$(echo "$CERT_INFO" | jq -r '.Certificate.DomainValidationOptions[0].ValidationMethod')
    
    echo "   Domain: $CERT_DOMAIN"
    echo "   Status: $CERT_STATUS"
    echo "   Type: $CERT_TYPE"
    echo "   Validation Method: $VALIDATION_METHOD"
else
    echo "❌ Cannot access certificate"
    echo "$CERT_INFO"
    ((ERRORS++))
    exit 1
fi
echo ""

# Test 2: Certificate domains match
echo "Test 2: Certificate Domains"
CERT_DOMAINS=$(echo "$CERT_INFO" | jq -r '.Certificate.DomainValidationOptions[].DomainName')
EXPECTED_DOMAINS=("$DOMAIN_NAME" "www.$DOMAIN_NAME")

for expected in "${EXPECTED_DOMAINS[@]}"; do
    if echo "$CERT_DOMAINS" | grep -q "^$expected$"; then
        echo "✅ Domain found: $expected"
    else
        echo "❌ Domain missing: $expected"
        ((ERRORS++))
    fi
done
echo ""

# Test 3: Validation records from certificate
echo "Test 3: Validation Records (from Certificate)"
VALIDATION_OPTIONS=$(echo "$CERT_INFO" | jq -c '.Certificate.DomainValidationOptions[] | select(.ResourceRecord != null)')

if [ -z "$VALIDATION_OPTIONS" ]; then
    echo "❌ No validation records found in certificate"
    ((ERRORS++))
else
    RECORD_COUNT=$(echo "$VALIDATION_OPTIONS" | wc -l | tr -d ' ')
    echo "✅ Found $RECORD_COUNT validation record(s)"
    
    # Get first record
    RECORD1=$(echo "$VALIDATION_OPTIONS" | head -1)
    RECORD1_NAME=$(echo "$RECORD1" | jq -r '.ResourceRecord.Name // empty')
    RECORD1_VALUE=$(echo "$RECORD1" | jq -r '.ResourceRecord.Value // empty')
    
    # Get second record if exists
    RECORD2=$(echo "$VALIDATION_OPTIONS" | tail -1)
    if [ "$RECORD2" != "$RECORD1" ]; then
        RECORD2_NAME=$(echo "$RECORD2" | jq -r '.ResourceRecord.Name // empty')
        RECORD2_VALUE=$(echo "$RECORD2" | jq -r '.ResourceRecord.Value // empty')
    else
        RECORD2_NAME=""
        RECORD2_VALUE=""
    fi
    
    if [ -n "$RECORD1_NAME" ] && [ -n "$RECORD1_VALUE" ]; then
        echo "   Record 1: $RECORD1_NAME -> $RECORD1_VALUE"
    fi
    if [ -n "$RECORD2_NAME" ] && [ -n "$RECORD2_VALUE" ]; then
        echo "   Record 2: $RECORD2_NAME -> $RECORD2_VALUE"
    fi
fi
echo ""

# Test 4: Hosted zone exists
echo "Test 4: Route 53 Hosted Zone"
HOSTED_ZONE=$(aws route53 get-hosted-zone \
    --id "$HOSTED_ZONE_ID" \
    --profile "$PROFILE" \
    2>&1)

if [ $? -eq 0 ]; then
    ZONE_NAME=$(echo "$HOSTED_ZONE" | jq -r '.HostedZone.Name')
    echo "✅ Hosted zone exists: $ZONE_NAME"
    
    if [ "$ZONE_NAME" == "$DOMAIN_NAME." ]; then
        echo "✅ Zone name matches domain"
    else
        echo "⚠️  Zone name ($ZONE_NAME) doesn't match domain ($DOMAIN_NAME.)"
        ((WARNINGS++))
    fi
else
    echo "❌ Cannot access hosted zone"
    echo "$HOSTED_ZONE"
    ((ERRORS++))
fi
echo ""

# Test 5: Validation records in Route 53
echo "Test 5: Validation Records in Route 53"
R53_RECORDS=$(aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --profile "$PROFILE" \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Cannot list Route 53 records"
    echo "$R53_RECORDS"
    ((ERRORS++))
else
    if [ -n "$RECORD1_NAME" ]; then
        RECORD1_EXISTS=$(echo "$R53_RECORDS" | jq -r ".ResourceRecordSets[] | select(.Name == \"$RECORD1_NAME\") | .Name" | head -1)
        RECORD1_R53_VALUE=$(echo "$R53_RECORDS" | jq -r ".ResourceRecordSets[] | select(.Name == \"$RECORD1_NAME\") | .ResourceRecords[0].Value" | head -1)
        
        if [ -n "$RECORD1_EXISTS" ] && [ "$RECORD1_EXISTS" != "null" ]; then
            echo "✅ Record 1 exists in Route 53: $RECORD1_NAME"
            if [ "$RECORD1_R53_VALUE" == "$RECORD1_VALUE" ]; then
                echo "✅ Record 1 value matches certificate"
            else
                echo "❌ Record 1 value mismatch!"
                echo "   Expected: $RECORD1_VALUE"
                echo "   Found:    $RECORD1_R53_VALUE"
                ((ERRORS++))
            fi
        else
            echo "❌ Record 1 missing in Route 53: $RECORD1_NAME"
            ((ERRORS++))
        fi
    fi
    
    if [ -n "$RECORD2_NAME" ]; then
        RECORD2_EXISTS=$(echo "$R53_RECORDS" | jq -r ".ResourceRecordSets[] | select(.Name == \"$RECORD2_NAME\") | .Name" | head -1)
        RECORD2_R53_VALUE=$(echo "$R53_RECORDS" | jq -r ".ResourceRecordSets[] | select(.Name == \"$RECORD2_NAME\") | .ResourceRecords[0].Value" | head -1)
        
        if [ -n "$RECORD2_EXISTS" ] && [ "$RECORD2_EXISTS" != "null" ]; then
            echo "✅ Record 2 exists in Route 53: $RECORD2_NAME"
            if [ "$RECORD2_R53_VALUE" == "$RECORD2_VALUE" ]; then
                echo "✅ Record 2 value matches certificate"
            else
                echo "❌ Record 2 value mismatch!"
                echo "   Expected: $RECORD2_VALUE"
                echo "   Found:    $RECORD2_R53_VALUE"
                ((ERRORS++))
            fi
        else
            echo "❌ Record 2 missing in Route 53: $RECORD2_NAME"
            ((ERRORS++))
        fi
    fi
fi
echo ""

# Test 6: DNS propagation check (using dig if available)
echo "Test 6: DNS Propagation Check"
if command -v dig &> /dev/null; then
    if [ -n "$RECORD1_NAME" ]; then
        DIG_RESULT=$(dig +short "$RECORD1_NAME" CNAME 2>&1 || echo "dig_failed")
        if [ "$DIG_RESULT" != "dig_failed" ] && [ -n "$DIG_RESULT" ]; then
            echo "✅ DNS record is resolvable: $RECORD1_NAME"
            echo "   Resolves to: $DIG_RESULT"
        else
            echo "⚠️  DNS record not yet resolvable: $RECORD1_NAME"
            echo "   This is normal - DNS propagation can take a few minutes"
            ((WARNINGS++))
        fi
    fi
else
    echo "ℹ️  'dig' command not available - skipping DNS propagation check"
fi
echo ""

# Test 7: Certificate validation status details
echo "Test 7: Certificate Validation Details"
VALIDATION_DETAILS=$(echo "$CERT_INFO" | jq -r '.Certificate.DomainValidationOptions[]')

VALIDATION_COUNT=0
PENDING_COUNT=0
SUCCESS_COUNT=0

while IFS= read -r validation; do
    if [ -n "$validation" ] && [ "$validation" != "null" ]; then
        VAL_DOMAIN=$(echo "$validation" | jq -r '.DomainName')
        VAL_STATUS=$(echo "$validation" | jq -r '.ValidationStatus // "UNKNOWN"')
        VAL_METHOD=$(echo "$validation" | jq -r '.ValidationMethod')
        
        ((VALIDATION_COUNT++))
        
        echo "   Domain: $VAL_DOMAIN"
        echo "   Status: $VAL_STATUS"
        echo "   Method: $VAL_METHOD"
        
        if [ "$VAL_STATUS" == "PENDING_VALIDATION" ]; then
            ((PENDING_COUNT++))
        elif [ "$VAL_STATUS" == "SUCCESS" ]; then
            ((SUCCESS_COUNT++))
        fi
        echo ""
    fi
done <<< "$(echo "$VALIDATION_DETAILS" | jq -c '.')"

# Summary
echo "============================================================"
echo "Diagnostic Summary"
echo "============================================================"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo "Certificate Status: $CERT_STATUS"
echo "Validation Records: $VALIDATION_COUNT"
echo "Pending: $PENDING_COUNT"
echo "Success: $SUCCESS_COUNT"
echo ""

if [ $ERRORS -eq 0 ]; then
    if [ "$CERT_STATUS" == "PENDING_VALIDATION" ]; then
        echo "✅ Everything is configured correctly!"
        echo ""
        echo "The certificate is pending validation, which is normal."
        echo "AWS is verifying the DNS records - this typically takes:"
        echo "  - 5-15 minutes (most common)"
        echo "  - Up to 30 minutes (occasionally)"
        echo "  - Rarely up to 1 hour"
        echo ""
        echo "Your setup is correct - just wait for AWS to complete validation."
        echo ""
        echo "Check again in 10-15 minutes:"
        echo "  ./check-cert-and-continue.sh"
    elif [ "$CERT_STATUS" == "ISSUED" ]; then
        echo "✅ Certificate is validated and ready!"
        echo ""
        echo "Run: ./continue-cloudfront-setup.sh"
    else
        echo "⚠️  Certificate status: $CERT_STATUS"
        echo "   Check AWS Console for details"
    fi
else
    echo "❌ Found $ERRORS error(s) - please review above"
    echo "   Fix the errors and run this script again"
fi

if [ $WARNINGS -gt 0 ]; then
    echo ""
    echo "⚠️  Found $WARNINGS warning(s) - these are usually not critical"
fi

echo "============================================================"
