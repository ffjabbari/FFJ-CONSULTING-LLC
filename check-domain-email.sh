#!/bin/bash

# Check if domain is registered to user's email

DOMAIN_NAME="ffjconsulting.com"
USER_EMAIL="ffjabbari@gmail.com"

echo "============================================================"
echo "Domain Email Ownership Check"
echo "============================================================"
echo "Domain: $DOMAIN_NAME"
echo "Your Email: $USER_EMAIL"
echo ""

# Run whois
if ! command -v whois &> /dev/null; then
    echo "❌ 'whois' command not available"
    echo "   Install with: brew install whois (on macOS)"
    exit 1
fi

echo "Checking WHOIS information..."
WHOIS_OUTPUT=$(whois "$DOMAIN_NAME" 2>&1)

# Extract email addresses from whois
EMAILS=$(echo "$WHOIS_OUTPUT" | grep -iE "email|e-mail|@.*\.com|@.*\.net|@.*\.org" | grep -i "@" | sed 's/.*\([a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]*\.[a-zA-Z]\{2,\}\).*/\1/' | sort -u)

echo ""
echo "============================================================"
echo "Email Check Results"
echo "============================================================"

FOUND_MATCH=false
FOUND_EMAILS=false

if [ -n "$EMAILS" ]; then
    FOUND_EMAILS=true
    echo "Email addresses found in WHOIS:"
    echo ""
    
    while IFS= read -r email; do
        if [ -n "$email" ]; then
            # Check if it matches user's email
            if [ "$email" == "$USER_EMAIL" ]; then
                echo "  ✅ $email - MATCHES YOUR EMAIL!"
                FOUND_MATCH=true
            else
                # Mask email for privacy
                MASKED=$(echo "$email" | sed 's/\(.\{2\}\).*@\(.*\)/\1***@\2/')
                echo "  ⚠️  $MASKED - Different email"
            fi
        fi
    done <<< "$EMAILS"
else
    echo "⚠️  No email addresses found in WHOIS output"
    echo "   (Some registrars hide email addresses for privacy)"
fi

echo ""
echo "============================================================"
echo "Analysis"
echo "============================================================"
echo ""

if [ "$FOUND_MATCH" = true ]; then
    echo "✅ DOMAIN IS REGISTERED TO YOU!"
    echo ""
    echo "The domain is registered with your email address."
    echo ""
    echo "Next steps:"
    echo "1. Log into your registrar account"
    echo "2. Find domain: $DOMAIN_NAME"
    echo "3. Update nameservers to Route 53"
    echo ""
    echo "Route 53 nameservers:"
    echo "  - ns-140.awsdns-17.com"
    echo "  - ns-1962.awsdns-53.co.uk"
    echo "  - ns-1488.awsdns-58.org"
    echo "  - ns-887.awsdns-46.net"
elif [ "$FOUND_EMAILS" = true ]; then
    echo "❌ DOMAIN IS NOT REGISTERED TO YOUR EMAIL"
    echo ""
    echo "The domain is registered to a different email address."
    echo ""
    echo "Options:"
    echo "1. If you have access to that email, you can update nameservers"
    echo "2. If you don't have access, you may need to:"
    echo "   - Contact the domain owner"
    echo "   - Register a different domain"
    echo "   - Wait for domain to expire and register it"
else
    echo "⚠️  Could not determine email ownership"
    echo ""
    echo "WHOIS may be hiding email addresses for privacy."
    echo ""
    echo "Check:"
    echo "1. Your email inbox for domain registration confirmation"
    echo "2. Your registrar account (GoDaddy, Namecheap, etc.)"
    echo "3. Credit card statements for domain registration charges"
fi

echo ""
echo "============================================================"
echo "Additional Information"
echo "============================================================"

# Extract registrar
REGISTRAR=$(echo "$WHOIS_OUTPUT" | grep -i "Registrar:" | head -1 | sed 's/.*Registrar: *//')
if [ -n "$REGISTRAR" ]; then
    echo "Registrar: $REGISTRAR"
    echo ""
    echo "To update nameservers:"
    echo "1. Go to $REGISTRAR website"
    echo "2. Log in with the email associated with the domain"
    echo "3. Find DNS/Nameserver settings"
    echo "4. Update to Route 53 nameservers"
fi

# Show nameservers
echo ""
echo "Current Nameservers:"
NS=$(echo "$WHOIS_OUTPUT" | grep -i "Name Server:" | sed 's/.*Name Server: *//')
if [ -n "$NS" ]; then
    echo "$NS" | while read ns; do
        echo "  - $ns"
    done
else
    echo "  (Not found in WHOIS)"
fi

echo ""
echo "============================================================"
