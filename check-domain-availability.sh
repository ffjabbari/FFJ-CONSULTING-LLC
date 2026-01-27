#!/bin/bash

# Domain Availability Checker Script
# Run this locally to check domain availability

echo "============================================================"
echo "FFJ Consulting LLC - Domain Availability Check"
echo "============================================================"
echo ""

PROFILE="my-sso"
REGION="us-east-1"

DOMAINS=(
    "ffjconsulting.com"
    "ffj-consulting.com"
    "ffjconsultingllc.com"
    "ffjconsulting.cloud"
    "ffjconsulting.ai"
)

echo "Checking domain availability..."
echo ""

for domain in "${DOMAINS[@]}"; do
    echo "Checking: $domain"
    result=$(aws route53domains check-domain-availability \
        --domain-name "$domain" \
        --region "$REGION" \
        --profile "$PROFILE" \
        2>&1)
    
    if echo "$result" | grep -q "AVAILABLE"; then
        echo "  ✅ AVAILABLE"
    elif echo "$result" | grep -q "UNAVAILABLE"; then
        echo "  ❌ UNAVAILABLE"
    elif echo "$result" | grep -q "RESERVED"; then
        echo "  ⚠️  RESERVED"
    else
        echo "  ❓ Status: $result"
    fi
    echo ""
done

echo "============================================================"
echo "Note: If you see connection errors, check your AWS credentials"
echo "============================================================"
