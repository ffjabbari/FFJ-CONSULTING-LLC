#!/bin/bash

# Check Certificate Request Time and Duration

PROFILE="my-sso"
REGION="us-east-1"
CERT_ARN="arn:aws:acm:us-east-1:678113404782:certificate/9ca7d55a-41cf-4441-87e0-0b5b739d6164"

echo "============================================================"
echo "Certificate Request Timing Analysis"
echo "============================================================"
echo ""

# Get certificate details
CERT_INFO=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --output json 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Error getting certificate info:"
    echo "$CERT_INFO"
    exit 1
fi

# Extract information
STATUS=$(echo "$CERT_INFO" | jq -r '.Certificate.Status')
REQUESTED_AT=$(echo "$CERT_INFO" | jq -r '.Certificate.CreatedAt')
DOMAIN=$(echo "$CERT_INFO" | jq -r '.Certificate.DomainName')

echo "Certificate Details:"
echo "  Domain: $DOMAIN"
echo "  Status: $STATUS"
echo "  Requested At: $REQUESTED_AT"
echo ""

# Convert to readable format and calculate duration
if command -v python3 &> /dev/null; then
    # Calculate time difference
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    
    DURATION=$(python3 <<EOF
from datetime import datetime
import sys

requested = datetime.fromisoformat("$REQUESTED_AT".replace('Z', '+00:00'))
now = datetime.fromisoformat("$NOW".replace('Z', '+00:00'))
diff = now - requested

hours = diff.total_seconds() / 3600
minutes = (diff.total_seconds() % 3600) / 60

print(f"{int(hours)} hours and {int(minutes)} minutes")
EOF
)
    
    echo "Time Since Request: $DURATION"
    echo ""
    
    # Check if it's been too long
    HOURS=$(echo "$DURATION" | awk '{print $1}')
    if [ "$HOURS" -gt 1 ]; then
        echo "⚠️  WARNING: Certificate has been pending for over 1 hour"
        echo "   This is longer than typical (5-30 minutes)"
        echo ""
        echo "Possible issues:"
        echo "  1. DNS records may not be resolving correctly"
        echo "  2. Domain may not be registered yet"
        echo "  3. Nameservers may not be updated at registrar"
        echo ""
        echo "Next steps:"
        echo "  1. Verify domain is registered: ffjconsulting.com"
        echo "  2. Check if nameservers are updated at registrar"
        echo "  3. Run: ./diagnose-certificate-simple.sh for detailed check"
    else
        echo "✅ Time elapsed is within normal range"
        echo "   Certificate validation typically takes 5-30 minutes"
        echo "   Sometimes up to 1 hour"
    fi
else
    echo "⚠️  Python3 not available - cannot calculate duration"
    echo "   Requested at: $REQUESTED_AT"
fi

echo ""
echo "============================================================"
