#!/bin/bash

# Check Domain Ownership and Registration Details

DOMAIN_NAME="ffjconsulting.com"

echo "============================================================"
echo "Domain Ownership Check"
echo "============================================================"
echo "Domain: $DOMAIN_NAME"
echo ""

# Method 1: Using whois
echo "Method 1: WHOIS Lookup"
echo "----------------------"
if command -v whois &> /dev/null; then
    WHOIS_INFO=$(whois "$DOMAIN_NAME" 2>&1)
    
    # Extract key information
    REGISTRAR=$(echo "$WHOIS_INFO" | grep -i "Registrar:" | head -1 | sed 's/.*Registrar: *//')
    REGISTRANT_NAME=$(echo "$WHOIS_INFO" | grep -i "Registrant Name:" | head -1 | sed 's/.*Registrant Name: *//')
    REGISTRANT_ORG=$(echo "$WHOIS_INFO" | grep -i "Registrant Organization:" | head -1 | sed 's/.*Registrant Organization: *//')
    REGISTRANT_EMAIL=$(echo "$WHOIS_INFO" | grep -i "Registrant Email:" | head -1 | sed 's/.*Registrant Email: *//' | head -1)
    CREATION_DATE=$(echo "$WHOIS_INFO" | grep -i "Creation Date:" | head -1 | sed 's/.*Creation Date: *//')
    EXPIRY_DATE=$(echo "$WHOIS_INFO" | grep -i "Expiry Date:" | head -1 | sed 's/.*Expiry Date: *//')
    NAMESERVERS=$(echo "$WHOIS_INFO" | grep -i "Name Server:" | sed 's/.*Name Server: *//' | tr '\n' ',' | sed 's/,$//')
    
    if [ -n "$REGISTRAR" ]; then
        echo "✅ Registrar: $REGISTRAR"
    fi
    
    if [ -n "$REGISTRANT_NAME" ]; then
        echo "   Registrant Name: $REGISTRANT_NAME"
    fi
    
    if [ -n "$REGISTRANT_ORG" ]; then
        echo "   Registrant Organization: $REGISTRANT_ORG"
    fi
    
    if [ -n "$REGISTRANT_EMAIL" ]; then
        # Mask email for privacy
        MASKED_EMAIL=$(echo "$REGISTRANT_EMAIL" | sed 's/\(.\{2\}\).*@\(.*\)/\1***@\2/')
        echo "   Registrant Email: $MASKED_EMAIL"
        echo ""
        echo "   ⚠️  Check if this email matches yours"
    fi
    
    if [ -n "$CREATION_DATE" ]; then
        echo "   Creation Date: $CREATION_DATE"
    fi
    
    if [ -n "$EXPIRY_DATE" ]; then
        echo "   Expiry Date: $EXPIRY_DATE"
    fi
    
    if [ -n "$NAMESERVERS" ]; then
        echo ""
        echo "   Current Nameservers:"
        echo "$WHOIS_INFO" | grep -i "Name Server:" | sed 's/.*Name Server: *//' | while read ns; do
            echo "     - $ns"
        done
    fi
    
    echo ""
    echo "Full WHOIS output (may contain your info):"
    echo "----------------------------------------"
    echo "$WHOIS_INFO" | head -50
    echo "..."
    
else
    echo "❌ 'whois' command not available"
    echo "   Install with: brew install whois (on macOS)"
fi

echo ""
echo "============================================================"
echo "Method 2: DNS Lookup"
echo "============================================================"

# Check if domain resolves
if command -v dig &> /dev/null; then
    echo "Checking if domain resolves..."
    DNS_RESULT=$(dig +short "$DOMAIN_NAME" 2>&1)
    
    if [ -n "$DNS_RESULT" ] && [ "$DNS_RESULT" != "connection timed out" ]; then
        echo "✅ Domain resolves to:"
        echo "$DNS_RESULT" | while read ip; do
            echo "   - $ip"
        done
    else
        echo "⚠️  Domain does not resolve (may not be configured)"
    fi
    
    # Check nameservers
    echo ""
    echo "Current Nameservers:"
    NS_RESULT=$(dig +short NS "$DOMAIN_NAME" 2>&1)
    if [ -n "$NS_RESULT" ] && [ "$NS_RESULT" != "connection timed out" ]; then
        echo "$NS_RESULT" | while read ns; do
            echo "   - $ns"
        done
    else
        echo "   ⚠️  Could not resolve nameservers"
    fi
else
    echo "❌ 'dig' command not available"
    echo "   Install with: brew install bind (on macOS)"
fi

echo ""
echo "============================================================"
echo "Analysis"
echo "============================================================"
echo ""

# Check if it might be the user's domain
if [ -n "$REGISTRANT_EMAIL" ]; then
    echo "To verify if this is YOUR domain:"
    echo "1. Check the registrant email shown above"
    echo "2. Check your email for domain registration confirmation"
    echo "3. Check if the organization name matches 'FFJ Consulting LLC'"
    echo ""
fi

if [ -n "$REGISTRAR" ]; then
    echo "Domain is registered with: $REGISTRAR"
    echo ""
    echo "Next steps:"
    echo "1. Log into $REGISTRAR"
    echo "2. Find domain: $DOMAIN_NAME"
    echo "3. Update nameservers to Route 53"
    echo ""
    echo "Route 53 nameservers:"
    echo "  - ns-140.awsdns-17.com"
    echo "  - ns-1962.awsdns-53.co.uk"
    echo "  - ns-1488.awsdns-58.org"
    echo "  - ns-887.awsdns-46.net"
else
    echo "⚠️  Could not determine registrar"
    echo "   Check your email for domain registration confirmation"
fi

echo ""
echo "============================================================"
