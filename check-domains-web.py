#!/usr/bin/env python3
"""
Domain Availability Checker using public APIs
"""

import requests
import json

def check_domain_whois(domain):
    """Check domain using whois API"""
    try:
        # Using a free whois API
        url = f"https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=demo&domainName={domain}&outputFormat=JSON"
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            if 'WhoisRecord' in data:
                return "UNAVAILABLE"
            return "UNKNOWN"
    except:
        pass
    return None

def check_domain_dns(domain):
    """Check if domain has DNS records (indicates it's taken)"""
    try:
        import socket
        socket.gethostbyname(domain)
        return "UNAVAILABLE"  # Has DNS, likely taken
    except socket.gaierror:
        return "POSSIBLY_AVAILABLE"  # No DNS, might be available
    except:
        return None

def main():
    domains = [
        "ffjconsulting.com",
        "ffj-consulting.com",
        "ffjconsultingllc.com",
        "ffjconsulting.cloud",
        "ffjconsulting.ai"
    ]
    
    print("=" * 60)
    print("FFJ Consulting LLC - Domain Availability Check")
    print("=" * 60)
    print()
    print("Checking domains...")
    print("(Note: This is a quick check. For accurate results,")
    print(" use AWS Route 53 Console or namecheap.com)")
    print()
    
    for domain in domains:
        print(f"Checking: {domain}")
        
        # Try DNS check first
        dns_result = check_domain_dns(domain)
        
        if dns_result == "UNAVAILABLE":
            print(f"  ❌ LIKELY UNAVAILABLE (has DNS records)")
        elif dns_result == "POSSIBLY_AVAILABLE":
            print(f"  ✅ POSSIBLY AVAILABLE (no DNS found)")
        else:
            print(f"  ❓ Could not determine (check manually)")
        print()
    
    print("=" * 60)
    print("RECOMMENDATION:")
    print("For accurate availability and pricing, check:")
    print("1. AWS Route 53 Console: https://console.aws.amazon.com/route53/")
    print("2. Namecheap: https://www.namecheap.com/domains/registration/")
    print("3. GoDaddy: https://www.godaddy.com/")
    print("=" * 60)

if __name__ == "__main__":
    main()
