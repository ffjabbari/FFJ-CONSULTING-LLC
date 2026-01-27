#!/bin/bash

# Check Domain Nameservers and Guide Update

DOMAIN_NAME="ffjconsulting.com"
HOSTED_ZONE_ID="Z0268429M8AW2ZUY4ECU"
PROFILE="my-sso"

echo "============================================================"
echo "Domain Nameserver Check"
echo "============================================================"
echo "Domain: $DOMAIN_NAME"
echo ""

# Get Route 53 nameservers
echo "Route 53 Nameservers (where domain should point):"
ROUTE53_NS=$(aws route53 get-hosted-zone \
    --id "$HOSTED_ZONE_ID" \
    --profile "$PROFILE" \
    --query 'DelegationSet.NameServers' \
    --output text 2>&1)

if [ $? -eq 0 ]; then
    echo "$ROUTE53_NS" | tr '\t' '\n' | while read ns; do
        echo "  - $ns"
    done
else
    echo "  Error getting Route 53 nameservers"
    echo "$ROUTE53_NS"
fi
echo ""

# Check current nameservers (using dig if available)
echo "Current Domain Nameservers:"
if command -v dig &> /dev/null; then
    CURRENT_NS=$(dig +short NS "$DOMAIN_NAME" 2>&1)
    if [ -n "$CURRENT_NS" ] && [ "$CURRENT_NS" != "connection timed out" ]; then
        echo "$CURRENT_NS" | while read ns; do
            echo "  - $ns"
        done
    else
        echo "  ⚠️  Could not resolve nameservers (domain may not be configured)"
    fi
else
    echo "  ℹ️  'dig' command not available"
    echo "  Install with: brew install bind (on macOS)"
fi
echo ""

# Check if nameservers match
echo "============================================================"
echo "Analysis"
echo "============================================================"

MATCH_COUNT=0
if command -v dig &> /dev/null && [ -n "$CURRENT_NS" ]; then
    for route53_ns in $ROUTE53_NS; do
        if echo "$CURRENT_NS" | grep -q "$route53_ns"; then
            ((MATCH_COUNT++))
        fi
    done
    
    if [ $MATCH_COUNT -gt 0 ]; then
        echo "✅ Found $MATCH_COUNT matching nameserver(s)"
        echo "   Domain may be partially configured"
    else
        echo "❌ Nameservers do NOT match Route 53"
        echo "   This is why certificate validation is stuck!"
    fi
else
    echo "⚠️  Could not verify nameserver match"
fi

echo ""
echo "============================================================"
echo "Next Steps"
echo "============================================================"
echo ""
echo "The domain is registered, but nameservers need to be updated."
echo ""
echo "1. Go to your domain registrar (where you registered the domain)"
echo "   Common registrars: GoDaddy, Namecheap, Google Domains, etc."
echo ""
echo "2. Find DNS/Nameserver settings for: $DOMAIN_NAME"
echo ""
echo "3. Update nameservers to:"
echo "$ROUTE53_NS" | tr '\t' '\n' | while read ns; do
    echo "   - $ns"
done
echo ""
echo "4. Save changes and wait 5-30 minutes for DNS propagation"
echo ""
echo "5. Once nameservers are updated, certificate validation should proceed"
echo ""
echo "6. Check certificate status:"
echo "   ./check-cert-and-continue.sh"
echo ""
echo "============================================================"
