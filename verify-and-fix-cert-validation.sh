#!/bin/bash

# Verify and Fix Certificate Validation Records
# This script checks if records exist and creates them if needed

set -e

PROFILE="my-sso"
REGION="us-east-1"
DOMAIN_NAME="ffjconsulting.com"
HOSTED_ZONE_ID="Z0268429M8AW2ZUY4ECU"
CERT_ARN="arn:aws:acm:us-east-1:678113404782:certificate/9ca7d55a-41cf-4441-87e0-0b5b739d6164"

echo "============================================================"
echo "Verifying Certificate Validation Records"
echo "============================================================"
echo ""

# Step 1: Get validation records from certificate
echo "Step 1: Getting validation records from certificate..."
VALIDATION_RECORDS=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'Certificate.DomainValidationOptions[*].ResourceRecord' \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Error getting certificate info:"
    echo "$VALIDATION_RECORDS"
    exit 1
fi

RECORD1_NAME=$(echo "$VALIDATION_RECORDS" | jq -r '.[0].Name')
RECORD1_VALUE=$(echo "$VALIDATION_RECORDS" | jq -r '.[0].Value')
RECORD2_NAME=$(echo "$VALIDATION_RECORDS" | jq -r '.[1].Name')
RECORD2_VALUE=$(echo "$VALIDATION_RECORDS" | jq -r '.[1].Value')

echo "Expected validation records:"
echo "  1. $RECORD1_NAME -> $RECORD1_VALUE"
echo "  2. $RECORD2_NAME -> $RECORD2_VALUE"
echo ""

# Step 2: Check if records exist in Route 53
echo "Step 2: Checking if records exist in Route 53..."
R53_RECORDS=$(aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --profile "$PROFILE" \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Error getting Route 53 records:"
    echo "$R53_RECORDS"
    exit 1
fi

# Check for first record
RECORD1_EXISTS=$(echo "$R53_RECORDS" | jq -r ".ResourceRecordSets[] | select(.Name == \"$RECORD1_NAME\") | .Name" | head -1)
RECORD2_EXISTS=$(echo "$R53_RECORDS" | jq -r ".ResourceRecordSets[] | select(.Name == \"$RECORD2_NAME\") | .Name" | head -1)

RECORDS_NEEDED=false

if [ -z "$RECORD1_EXISTS" ] || [ "$RECORD1_EXISTS" == "null" ]; then
    echo "⚠️  Record 1 missing: $RECORD1_NAME"
    RECORDS_NEEDED=true
else
    echo "✅ Record 1 exists: $RECORD1_NAME"
fi

if [ -z "$RECORD2_EXISTS" ] || [ "$RECORD2_EXISTS" == "null" ]; then
    echo "⚠️  Record 2 missing: $RECORD2_NAME"
    RECORDS_NEEDED=true
else
    echo "✅ Record 2 exists: $RECORD2_NAME"
fi

echo ""

# Step 3: Create records if needed
if [ "$RECORDS_NEEDED" = true ]; then
    echo "Step 3: Creating missing validation records..."
    
    CHANGE_BATCH=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$RECORD1_NAME",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$RECORD1_VALUE"
          }
        ]
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$RECORD2_NAME",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$RECORD2_VALUE"
          }
        ]
      }
    }
  ]
}
EOF
)
    
    echo "$CHANGE_BATCH" > /tmp/validation-records.json
    
    RESULT=$(aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch file:///tmp/validation-records.json \
        --profile "$PROFILE" \
        2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✅ Validation records created successfully!"
    else
        echo "❌ Failed to create validation records:"
        echo "$RESULT"
        exit 1
    fi
else
    echo "Step 3: All validation records already exist ✅"
fi

echo ""

# Step 4: Check certificate status
echo "Step 4: Checking certificate status..."
CERT_STATUS=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'Certificate.Status' \
    --output text 2>&1)

echo "Certificate status: $CERT_STATUS"
echo ""

if [ "$CERT_STATUS" = "ISSUED" ]; then
    echo "✅ Certificate is validated and ready!"
    echo ""
    echo "You can now run: ./continue-cloudfront-setup.sh"
elif [ "$CERT_STATUS" = "PENDING_VALIDATION" ]; then
    echo "⏳ Certificate is still being validated..."
    echo ""
    if [ "$RECORDS_NEEDED" = true ]; then
        echo "✅ Validation records have been created"
        echo "   AWS will now verify them (5-30 minutes)"
    else
        echo "✅ Validation records exist"
        echo "   Waiting for AWS to verify them (5-30 minutes)"
    fi
    echo ""
    echo "Run this script again in 10-15 minutes to check status:"
    echo "  ./verify-and-fix-cert-validation.sh"
    echo ""
    echo "Or use the auto-continue script:"
    echo "  ./check-cert-and-continue.sh"
else
    echo "Certificate status: $CERT_STATUS"
fi

echo ""
echo "============================================================"
