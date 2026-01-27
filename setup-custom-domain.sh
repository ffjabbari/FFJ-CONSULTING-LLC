#!/bin/bash

# Custom Domain Setup Script for FFJ Consulting LLC
# This script sets up Route 53, SSL, and CloudFront for custom domain

set -e

DOMAIN_NAME="ffjconsulting.com"
BUCKET_NAME="ffj-consulting-website"
PROFILE="my-sso"
REGION="us-east-1"
HOSTED_ZONE_NAME="${DOMAIN_NAME}."

echo "============================================================"
echo "FFJ Consulting LLC - Custom Domain Setup"
echo "============================================================"
echo "Domain: $DOMAIN_NAME"
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "Profile: $PROFILE"
echo "============================================================"
echo ""

# Step 1: Check if domain is registered
echo "Step 1: Checking domain registration..."
if aws route53domains list-domains --region us-east-1 --profile "$PROFILE" 2>/dev/null | grep -q "$DOMAIN_NAME"; then
    echo "✅ Domain is registered"
else
    echo "⚠️  Domain not found in your AWS account"
    echo "   You may need to register it first via AWS Console:"
    echo "   https://console.aws.amazon.com/route53/home#DomainListing:"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# Step 2: Create Route 53 Hosted Zone
echo "Step 2: Creating Route 53 Hosted Zone..."
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
    --dns-name "$HOSTED_ZONE_NAME" \
    --profile "$PROFILE" \
    2>/dev/null | jq -r '.HostedZones[0].Id // empty' | sed 's|/hostedzone/||')

if [ -z "$HOSTED_ZONE_ID" ] || [ "$HOSTED_ZONE_ID" == "null" ]; then
    echo "Creating new hosted zone..."
    HOSTED_ZONE=$(aws route53 create-hosted-zone \
        --name "$HOSTED_ZONE_NAME" \
        --caller-reference "ffj-consulting-$(date +%s)" \
        --profile "$PROFILE" \
        2>&1)
    
    if [ $? -eq 0 ]; then
        HOSTED_ZONE_ID=$(echo "$HOSTED_ZONE" | jq -r '.HostedZone.Id' | sed 's|/hostedzone/||')
        echo "✅ Hosted zone created: $HOSTED_ZONE_ID"
        echo ""
        echo "IMPORTANT: Update your domain registrar with these nameservers:"
        echo "$HOSTED_ZONE" | jq -r '.DelegationSet.NameServers[]' | while read ns; do
            echo "  - $ns"
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

# Step 3: Request SSL Certificate
echo "Step 3: Requesting SSL Certificate in ACM..."
CERT_ARN=$(aws acm list-certificates \
    --region "$REGION" \
    --profile "$PROFILE" \
    2>/dev/null | jq -r ".CertificateSummaryList[] | select(.DomainName == \"$DOMAIN_NAME\" or .DomainName == \"*.$DOMAIN_NAME\") | .CertificateArn" | head -1)

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
        echo "IMPORTANT: You need to validate the certificate by adding DNS records."
        echo "Getting validation records..."
        sleep 5
        VALIDATION=$(aws acm describe-certificate \
            --certificate-arn "$CERT_ARN" \
            --region "$REGION" \
            --profile "$PROFILE" \
            2>&1 | jq -r '.Certificate.DomainValidationOptions[]')
        
        echo "Add these CNAME records to your Route 53 hosted zone:"
        echo "$VALIDATION" | jq -r '.ResourceRecord | "Name: \(.Name), Value: \(.Value)"'
        echo ""
        echo "The script will continue, but certificate won't be valid until DNS records are added."
    else
        echo "❌ Failed to request certificate"
        echo "$CERT_REQUEST"
        exit 1
    fi
else
    echo "✅ Certificate already exists: $CERT_ARN"
    
    # Check if certificate is validated
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

# Step 4: Create CloudFront Distribution
echo "Step 4: Creating CloudFront Distribution..."
echo "This step requires the certificate to be validated first."
echo "Creating distribution configuration..."

# Get S3 website endpoint
S3_ENDPOINT="$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

# Create CloudFront distribution config
cat > /tmp/cloudfront-config.json <<EOF
{
  "CallerReference": "ffj-consulting-$(date +%s)",
  "Comment": "FFJ Consulting LLC Website",
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-$BUCKET_NAME",
        "DomainName": "$S3_ENDPOINT",
        "CustomOriginConfig": {
          "HTTPPort": 80,
          "HTTPSPort": 443,
          "OriginProtocolPolicy": "http-only",
          "OriginSslProtocols": {
            "Quantity": 1,
            "Items": ["TLSv1.2"]
          }
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-$BUCKET_NAME",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 7,
      "Items": ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"],
      "CachedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"]
      }
    },
    "Compress": true,
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    },
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000
  },
  "CustomErrorResponses": {
    "Quantity": 1,
    "Items": [
      {
        "ErrorCode": 404,
        "ResponsePagePath": "/index.html",
        "ResponseCode": "200",
        "ErrorCachingMinTTL": 300
      }
    ]
  },
  "Enabled": true,
  "Aliases": {
    "Quantity": 2,
    "Items": ["$DOMAIN_NAME", "www.$DOMAIN_NAME"]
  },
  "ViewerCertificate": {
    "ACMCertificateArn": "$CERT_ARN",
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.2_2021"
  },
  "PriceClass": "PriceClass_100"
}
EOF

echo "CloudFront distribution configuration created."
echo "⚠️  Note: CloudFront distribution creation must be done via AWS Console"
echo "   or AWS CLI with proper certificate validation."
echo ""
echo "To create the distribution, run:"
echo "aws cloudfront create-distribution --distribution-config file:///tmp/cloudfront-config.json --profile $PROFILE"
echo ""

echo "============================================================"
echo "Setup Progress Summary"
echo "============================================================"
echo "✅ Hosted Zone: $HOSTED_ZONE_ID"
echo "✅ Certificate ARN: $CERT_ARN"
echo "⚠️  Next Steps:"
echo "   1. Validate SSL certificate (add DNS records)"
echo "   2. Create CloudFront distribution"
echo "   3. Update DNS records to point to CloudFront"
echo "   4. Update website code with new domain"
echo "============================================================"
