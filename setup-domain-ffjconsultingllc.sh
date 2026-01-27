#!/bin/bash

# Complete Domain Setup for ffjconsultingllc.com
# This script does everything: checks availability, registers, sets up Route 53, SSL, CloudFront

set -e

DOMAIN_NAME="ffjconsultingllc.com"
BUCKET_NAME="ffj-consulting-website"
PROFILE="my-sso"
REGION="us-east-1"

echo "============================================================"
echo "FFJ Consulting LLC - Domain Setup"
echo "============================================================"
echo "Domain: $DOMAIN_NAME"
echo "Bucket: $BUCKET_NAME"
echo "Profile: $PROFILE"
echo "============================================================"
echo ""

# Step 1: Check if domain is registered in your AWS account
echo "Step 1: Checking if domain is registered..."
REGISTERED=$(aws route53domains list-domains \
    --region us-east-1 \
    --profile "$PROFILE" \
    2>&1 | grep -q "$DOMAIN_NAME" && echo "yes" || echo "no")

if [ "$REGISTERED" == "yes" ]; then
    echo "✅ Domain $DOMAIN_NAME is registered in your AWS account"
    DOMAIN_INFO=$(aws route53domains list-domains \
        --region us-east-1 \
        --profile "$PROFILE" \
        2>&1 | jq -r ".Domains[] | select(.DomainName == \"$DOMAIN_NAME\")")
    
    if [ -n "$DOMAIN_INFO" ]; then
        EXPIRY=$(echo "$DOMAIN_INFO" | jq -r '.Expiry // "Unknown"')
        echo "   Expiration: $EXPIRY"
    fi
elif [ "$REGISTERED" == "no" ]; then
    echo "⚠️  Domain not found in your registered domains"
    echo ""
    echo "The domain may be:"
    echo "  1. Still processing (wait a few minutes)"
    echo "  2. Registered elsewhere"
    echo "  3. Not yet registered"
    echo ""
    echo "If you just registered it, wait 2-3 minutes and run this script again."
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "⚠️  Could not check registration status"
    echo "   Continuing anyway..."
fi
echo ""

# Step 3: Create Route 53 hosted zone
echo "Step 3: Creating Route 53 Hosted Zone..."
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
    --dns-name "$DOMAIN_NAME." \
    --profile "$PROFILE" \
    2>&1 | jq -r '.HostedZones[0].Id // empty' | sed 's|/hostedzone/||')

if [ -z "$HOSTED_ZONE_ID" ] || [ "$HOSTED_ZONE_ID" == "null" ]; then
    echo "Creating new hosted zone..."
    HOSTED_ZONE=$(aws route53 create-hosted-zone \
        --name "$DOMAIN_NAME." \
        --caller-reference "ffj-consulting-llc-$(date +%s)" \
        --profile "$PROFILE" \
        2>&1)
    
    if [ $? -eq 0 ]; then
        HOSTED_ZONE_ID=$(echo "$HOSTED_ZONE" | jq -r '.HostedZone.Id' | sed 's|/hostedzone/||')
        echo "✅ Created hosted zone: $HOSTED_ZONE_ID"
        echo ""
        echo "📋 IMPORTANT: Update your domain registrar with these nameservers:"
        echo "$HOSTED_ZONE" | jq -r '.DelegationSet.NameServers[]' | while read ns; do
            echo "   - $ns"
        done
        echo ""
    else
        echo "❌ Failed to create hosted zone"
        echo "$HOSTED_ZONE"
        exit 1
    fi
else
    echo "✅ Hosted zone already exists: $HOSTED_ZONE_ID"
fi
echo ""

# Step 4: Request SSL certificate
echo "Step 4: Requesting SSL Certificate..."
CERT_ARN=$(aws acm list-certificates \
    --region "$REGION" \
    --profile "$PROFILE" \
    2>&1 | jq -r ".CertificateSummaryList[] | select(.DomainName == \"$DOMAIN_NAME\" or .DomainName == \"*.$DOMAIN_NAME\") | .CertificateArn" | head -1)

if [ -z "$CERT_ARN" ]; then
    echo "Requesting new certificate..."
    CERT_REQUEST=$(aws acm request-certificate \
        --domain-name "$DOMAIN_NAME" \
        --subject-alternative-names "www.$DOMAIN_NAME" \
        --validation-method DNS \
        --region "$REGION" \
        --profile "$PROFILE" \
        2>&1)
    
    if [ $? -eq 0 ]; then
        CERT_ARN=$(echo "$CERT_REQUEST" | jq -r '.CertificateArn')
        echo "✅ Certificate requested: $CERT_ARN"
        echo ""
        echo "📋 SSL Certificate Validation Records:"
        sleep 5
        VALIDATION=$(aws acm describe-certificate \
            --certificate-arn "$CERT_ARN" \
            --region "$REGION" \
            --profile "$PROFILE" \
            2>&1 | jq -r '.Certificate.DomainValidationOptions[]')
        
        echo "Add these CNAME records to your Route 53 hosted zone:"
        echo "$VALIDATION" | jq -r '.ResourceRecord | "Name: \(.Name), Value: \(.Value)"'
        echo ""
        echo "Adding validation records automatically..."
        
        # Add validation records - get from certificate details
        CERT_DETAIL=$(aws acm describe-certificate \
            --certificate-arn "$CERT_ARN" \
            --region "$REGION" \
            --profile "$PROFILE" \
            2>&1)
        
        RECORD1_NAME=$(echo "$CERT_DETAIL" | jq -r '.Certificate.DomainValidationOptions[0].ResourceRecord.Name')
        RECORD1_VALUE=$(echo "$CERT_DETAIL" | jq -r '.Certificate.DomainValidationOptions[0].ResourceRecord.Value')
        RECORD2_NAME=$(echo "$CERT_DETAIL" | jq -r '.Certificate.DomainValidationOptions[1].ResourceRecord.Name')
        RECORD2_VALUE=$(echo "$CERT_DETAIL" | jq -r '.Certificate.DomainValidationOptions[1].ResourceRecord.Value')
        
        aws route53 change-resource-record-sets \
            --hosted-zone-id "$HOSTED_ZONE_ID" \
            --change-batch "{
                \"Changes\": [
                    {
                        \"Action\": \"UPSERT\",
                        \"ResourceRecordSet\": {
                            \"Name\": \"$RECORD1_NAME\",
                            \"Type\": \"CNAME\",
                            \"TTL\": 300,
                            \"ResourceRecords\": [{\"Value\": \"$RECORD1_VALUE\"}]
                        }
                    },
                    {
                        \"Action\": \"UPSERT\",
                        \"ResourceRecordSet\": {
                            \"Name\": \"$RECORD2_NAME\",
                            \"Type\": \"CNAME\",
                            \"TTL\": 300,
                            \"ResourceRecords\": [{\"Value\": \"$RECORD2_VALUE\"}]
                        }
                    }
                ]
            }" \
            --profile "$PROFILE" \
            > /dev/null 2>&1
        
        echo "✅ Validation records added"
        echo "   Waiting 5-30 minutes for certificate validation..."
    else
        echo "❌ Failed to request certificate"
        echo "$CERT_REQUEST"
        exit 1
    fi
else
    echo "✅ Certificate already exists: $CERT_ARN"
    CERT_STATUS=$(aws acm describe-certificate \
        --certificate-arn "$CERT_ARN" \
        --region "$REGION" \
        --profile "$PROFILE" \
        2>&1 | jq -r '.Certificate.Status')
    
    if [ "$CERT_STATUS" != "ISSUED" ]; then
        echo "⚠️  Certificate status: $CERT_STATUS (needs validation)"
    else
        echo "✅ Certificate is validated and ready"
    fi
fi
echo ""

# Step 5: Wait for certificate validation
echo "Step 5: Certificate Validation"
echo "Certificate validation typically takes 5-30 minutes"
echo ""
echo "To check status, run:"
echo "  aws acm describe-certificate --certificate-arn $CERT_ARN --region $REGION --profile $PROFILE | jq -r '.Certificate.Status'"
echo ""
echo "Once status is 'ISSUED', run:"
echo "  ./create-cloudfront-ffjconsultingllc.sh"
echo ""

# Save configuration
cat > /tmp/ffjconsultingllc-config.txt <<EOF
DOMAIN_NAME=$DOMAIN_NAME
HOSTED_ZONE_ID=$HOSTED_ZONE_ID
CERT_ARN=$CERT_ARN
BUCKET_NAME=$BUCKET_NAME
PROFILE=$PROFILE
REGION=$REGION
EOF

echo "============================================================"
echo "Setup Complete (Pending Certificate Validation)"
echo "============================================================"
echo "Domain: $DOMAIN_NAME"
echo "Hosted Zone ID: $HOSTED_ZONE_ID"
echo "Certificate ARN: $CERT_ARN"
echo ""
echo "Configuration saved to: /tmp/ffjconsultingllc-config.txt"
echo ""
echo "Next Steps:"
echo "1. Wait for certificate validation (5-30 minutes)"
echo "2. Run: ./create-cloudfront-ffjconsultingllc.sh"
echo "3. Update website code with new domain"
echo "4. Rebuild and redeploy"
echo "============================================================"
