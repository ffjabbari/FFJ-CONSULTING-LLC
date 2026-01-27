#!/bin/bash

# Add SSL Certificate Validation Records to Route 53
# Run this to validate your SSL certificate

PROFILE="my-sso"
REGION="us-east-1"
DOMAIN_NAME="ffjconsulting.com"
HOSTED_ZONE_ID="Z0268429M8AW2ZUY4ECU"
CERT_ARN="arn:aws:acm:us-east-1:678113404782:certificate/9ca7d55a-41cf-4441-87e0-0b5b739d6164"

echo "============================================================"
echo "Adding SSL Certificate Validation Records"
echo "============================================================"
echo ""

# Get validation records
echo "Getting validation records from certificate..."
VALIDATION_RECORDS=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'Certificate.DomainValidationOptions[*].ResourceRecord' \
    --output json)

echo "Validation records:"
echo "$VALIDATION_RECORDS" | jq '.'

# Create DNS records for validation
echo ""
echo "Adding validation records to Route 53..."

# First record
RECORD1_NAME=$(echo "$VALIDATION_RECORDS" | jq -r '.[0].Name')
RECORD1_VALUE=$(echo "$VALIDATION_RECORDS" | jq -r '.[0].Value')

# Second record
RECORD2_NAME=$(echo "$VALIDATION_RECORDS" | jq -r '.[1].Name')
RECORD2_VALUE=$(echo "$VALIDATION_RECORDS" | jq -r '.[1].Value')

# Create change batch
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

# Save to temp file
echo "$CHANGE_BATCH" > /tmp/validation-records.json

# Add records
RESULT=$(aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch file:///tmp/validation-records.json \
    --profile "$PROFILE" \
    2>&1)

if [ $? -eq 0 ]; then
    echo "✅ Validation records added successfully!"
    echo ""
    echo "Now waiting for certificate validation..."
    echo "This typically takes 5-30 minutes"
    echo ""
    echo "You can check status with:"
    echo "aws acm describe-certificate --certificate-arn $CERT_ARN --region $REGION --profile $PROFILE | jq -r '.Certificate.Status'"
    echo ""
    echo "Once status is 'ISSUED', run the setup script again to create CloudFront"
else
    echo "❌ Failed to add validation records"
    echo "$RESULT"
    exit 1
fi
