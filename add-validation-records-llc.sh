#!/bin/bash

# Add SSL Certificate Validation Records for ffjconsultingllc.com

PROFILE="my-sso"
REGION="us-east-1"
DOMAIN_NAME="ffjconsultingllc.com"
HOSTED_ZONE_ID="Z0844454G4Y3F6T2Z1VT"
CERT_ARN="arn:aws:acm:us-east-1:678113404782:certificate/a8e8b60c-ccfe-4ee2-b86f-2520d1d24d7e"

echo "============================================================"
echo "Adding SSL Certificate Validation Records"
echo "============================================================"
echo ""

# Get validation records from certificate
echo "Getting validation records from certificate..."
CERT_DETAIL=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    2>&1)

RECORD1_NAME=$(echo "$CERT_DETAIL" | jq -r '.Certificate.DomainValidationOptions[0].ResourceRecord.Name')
RECORD1_VALUE=$(echo "$CERT_DETAIL" | jq -r '.Certificate.DomainValidationOptions[0].ResourceRecord.Value')
RECORD2_NAME=$(echo "$CERT_DETAIL" | jq -r '.Certificate.DomainValidationOptions[1].ResourceRecord.Name')
RECORD2_VALUE=$(echo "$CERT_DETAIL" | jq -r '.Certificate.DomainValidationOptions[1].ResourceRecord.Value')

echo "Validation records:"
echo "  Record 1: $RECORD1_NAME -> $RECORD1_VALUE"
echo "  Record 2: $RECORD2_NAME -> $RECORD2_VALUE"
echo ""

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

echo "$CHANGE_BATCH" > /tmp/validation-records-llc.json

# Add records
echo "Adding validation records to Route 53..."
RESULT=$(aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch file:///tmp/validation-records-llc.json \
    --profile "$PROFILE" \
    2>&1)

if [ $? -eq 0 ]; then
    echo "✅ Validation records added successfully!"
    echo ""
    echo "Now waiting for certificate validation..."
    echo "This typically takes 5-30 minutes"
    echo ""
    echo "Check status with:"
    echo "  aws acm describe-certificate --certificate-arn $CERT_ARN --region $REGION --profile $PROFILE | jq -r '.Certificate.Status'"
    echo ""
    echo "Once status is 'ISSUED', run:"
    echo "  ./create-cloudfront-ffjconsultingllc.sh"
else
    echo "❌ Failed to add validation records"
    echo "$RESULT"
    exit 1
fi
