#!/usr/bin/env python3
"""
Check Availability of Multiple Domain Variations
This script checks various domain name options
"""

import boto3
import sys
from botocore.exceptions import ClientError

PROFILE = "my-sso"
REGION = "us-east-1"

# Domain variations to check
DOMAIN_OPTIONS = [
    "ffjabbari.com",
    "ffjabbari-consulting.com",
    "ffjconsulting.com",  # Already checked - unavailable
    "ffj-consulting.com",
    "ffjconsultingllc.com",
    "ffj-consulting-llc.com",
    "ffjabbari-llc.com",
    "ffjconsulting.net",
    "ffjconsulting.org",
    "ffjabbari.net",
    "ffjabbari.org",
    "ffjconsulting.cloud",
    "ffjconsulting.ai",
    "ffjabbari-consulting.net",
    "ffjabbari-consulting.org",
]

def check_domain_availability(route53domains_client, domain):
    """Check if a domain is available"""
    try:
        response = route53domains_client.check_domain_availability(
            DomainName=domain
        )
        return response.get('Availability', 'UNKNOWN')
    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', '')
        if error_code == 'InvalidInput':
            return 'INVALID'
        return 'ERROR'

def get_domain_price(route53domains_client, tld):
    """Get price for a TLD"""
    try:
        response = route53domains_client.list_prices(Tld=tld)
        for price in response.get('Prices', []):
            if price.get('Name') == 'registration':
                reg_price = price.get('Price', {})
                return reg_price.get('Price', 'Unknown')
    except:
        pass
    return None

def main():
    print("="*70)
    print("Domain Availability Check - FFJ Consulting LLC")
    print("="*70)
    print("")
    
    # Initialize AWS client
    try:
        session = boto3.Session(profile_name=PROFILE)
        route53domains_client = session.client('route53domains', region_name='us-east-1')
    except Exception as e:
        print(f"❌ Error connecting to AWS: {e}")
        print("")
        print("Please run this script on your machine where AWS CLI is configured.")
        sys.exit(1)
    
    # Get prices for common TLDs
    print("Getting domain prices...")
    prices = {}
    for tld in ['com', 'net', 'org', 'cloud', 'ai']:
        price = get_domain_price(route53domains_client, tld)
        if price:
            prices[tld] = price
    
    if prices:
        print("Domain Prices:")
        for tld, price in prices.items():
            print(f"  .{tld}: ${price}/year")
        print("")
    
    print("="*70)
    print("Checking Domain Availability")
    print("="*70)
    print("")
    
    available_domains = []
    unavailable_domains = []
    error_domains = []
    
    for domain in DOMAIN_OPTIONS:
        print(f"Checking: {domain:40}", end="", flush=True)
        availability = check_domain_availability(route53domains_client, domain)
        
        if availability == 'AVAILABLE':
            print(" ✅ AVAILABLE")
            available_domains.append(domain)
        elif availability == 'UNAVAILABLE':
            print(" ❌ UNAVAILABLE")
            unavailable_domains.append(domain)
        elif availability == 'RESERVED':
            print(" ⚠️  RESERVED")
            unavailable_domains.append(domain)
        elif availability == 'INVALID':
            print(" ⚠️  INVALID")
            error_domains.append(domain)
        else:
            print(f" ❓ {availability}")
            error_domains.append(domain)
    
    print("")
    print("="*70)
    print("Summary")
    print("="*70)
    print("")
    
    if available_domains:
        print(f"✅ AVAILABLE DOMAINS ({len(available_domains)}):")
        print("")
        for domain in available_domains:
            tld = domain.split('.')[-1]
            price = prices.get(tld, 'Unknown')
            print(f"  • {domain:40} (${price}/year)")
        print("")
        print("💡 RECOMMENDATION: Choose one of these available domains!")
        print("   Top picks:")
        if any('.com' in d for d in available_domains):
            com_domains = [d for d in available_domains if '.com' in d]
            print(f"   - {com_domains[0]} (best - .com is most professional)")
        if available_domains:
            print(f"   - {available_domains[0]} (first available option)")
    else:
        print("❌ No domains are available from the options checked")
        print("")
        print("Options:")
        print("  1. Try different variations")
        print("  2. Use a different TLD (.net, .org, .cloud)")
        print("  3. Consider a completely different domain name")
    
    if unavailable_domains:
        print("")
        print(f"❌ UNAVAILABLE DOMAINS ({len(unavailable_domains)}):")
        for domain in unavailable_domains[:5]:  # Show first 5
            print(f"  • {domain}")
        if len(unavailable_domains) > 5:
            print(f"  ... and {len(unavailable_domains) - 5} more")
    
    print("")
    print("="*70)
    print("Next Steps")
    print("="*70)
    print("")
    
    if available_domains:
        recommended = available_domains[0]
        print(f"1. Choose a domain (recommended: {recommended})")
        print("2. Register it via AWS Route 53 Console:")
        print("   https://console.aws.amazon.com/route53/home#DomainListing:")
        print("3. Or run: python3 register-domain-route53.py")
        print("4. Then continue with certificate and CloudFront setup")
    else:
        print("1. Consider alternative domain names")
        print("2. Try different TLDs (.net, .org, .cloud, .ai)")
        print("3. Use a domain name generator for ideas")
    
    print("")
    print("="*70)

if __name__ == "__main__":
    main()
