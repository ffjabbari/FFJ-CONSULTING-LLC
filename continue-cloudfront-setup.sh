#!/bin/bash

# Continue CloudFront Setup After Certificate Validation
# Run this after the certificate is validated

set -e

DOMAIN_NAME="ffjconsulting.com"
BUCKET_NAME="ffj-consulting-website"
PROFILE="my-sso"
REGION="us-east-1"
HOSTED_ZONE_ID="Z0268429M8AW2ZUY4ECU"
CERT_ARN="arn:aws:acm:us-east-1:678113404782:certificate/9ca7d55a-41cf-4441-87e0-0b5b739d6164"

echo "============================================================"
echo "Continuing CloudFront Setup"
echo "============================================================"
echo ""

# Check certificate status
echo "Checking certificate status..."
CERT_STATUS=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'Certificate.Status' \
    --output text)

echo "Certificate status: $CERT_STATUS"
echo ""

if [ "$CERT_STATUS" != "ISSUED" ]; then
    echo "❌ Certificate is not validated yet (status: $CERT_STATUS)"
    echo "   Please wait for validation or check the DNS records"
    exit 1
fi

echo "✅ Certificate is validated!"
echo ""

# Create CloudFront distribution
S3_ENDPOINT="$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

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

echo "Creating CloudFront distribution..."
CLOUDFRONT_RESULT=$(aws cloudfront create-distribution \
    --distribution-config file:///tmp/cloudfront-config.json \
    --profile "$PROFILE" \
    2>&1)

if [ $? -eq 0 ]; then
    DIST_ID=$(echo "$CLOUDFRONT_RESULT" | jq -r '.Distribution.Id')
    DIST_DOMAIN=$(echo "$CLOUDFRONT_RESULT" | jq -r '.Distribution.DomainName')
    echo "✅ CloudFront distribution created: $DIST_ID"
    echo "   Domain: $DIST_DOMAIN"
    echo ""
    
    # Create DNS records
    echo "Creating DNS records..."
    DNS_RESULT=$(aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch '{
          "Changes": [
            {
              "Action": "UPSERT",
              "ResourceRecordSet": {
                "Name": "'"$DOMAIN_NAME"'.",
                "Type": "A",
                "AliasTarget": {
                  "HostedZoneId": "Z2FDTNDATAQYW2",
                  "DNSName": "'"$DIST_DOMAIN"'",
                  "EvaluateTargetHealth": false
                }
              }
            },
            {
              "Action": "UPSERT",
              "ResourceRecordSet": {
                "Name": "www.'"$DOMAIN_NAME"'.",
                "Type": "A",
                "AliasTarget": {
                  "HostedZoneId": "Z2FDTNDATAQYW2",
                  "DNSName": "'"$DIST_DOMAIN"'",
                  "EvaluateTargetHealth": false
                }
              }
            }
          ]
        }' \
        --profile "$PROFILE" \
        2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✅ DNS records created for $DOMAIN_NAME and www.$DOMAIN_NAME"
    else
        echo "❌ Failed to create DNS records"
        echo "$DNS_RESULT"
        exit 1
    fi
    
    echo ""
    echo "============================================================"
    echo "Setup Complete!"
    echo "============================================================"
    echo "Domain: $DOMAIN_NAME"
    echo "Hosted Zone ID: $HOSTED_ZONE_ID"
    echo "Certificate ARN: $CERT_ARN"
    echo "CloudFront Distribution: $DIST_ID"
    echo "CloudFront Domain: $DIST_DOMAIN"
    echo ""
    echo "⚠️  Next Steps:"
    echo "   1. Wait for CloudFront deployment (15-30 minutes)"
    echo "   2. Update nameservers at your domain registrar:"
    echo "      - ns-140.awsdns-17.com"
    echo "      - ns-1962.awsdns-53.co.uk"
    echo "      - ns-1488.awsdns-58.org"
    echo "      - ns-887.awsdns-46.net"
    echo "   3. Tell me when ready - I'll update the website code"
    echo "   4. Test https://$DOMAIN_NAME"
    echo "============================================================"
else
    echo "❌ Failed to create CloudFront distribution"
    echo "$CLOUDFRONT_RESULT"
    exit 1
fi
