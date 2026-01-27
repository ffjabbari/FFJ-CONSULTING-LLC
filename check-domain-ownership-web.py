#!/usr/bin/env python3
"""
Check Domain Ownership using web-based WHOIS
"""

import subprocess
import sys
import json

DOMAIN_NAME = "ffjconsulting.com"

def run_whois():
    """Run whois command"""
    try:
        result = subprocess.run(
            ['whois', DOMAIN_NAME],
            capture_output=True,
            text=True,
            timeout=10
        )
        return result.stdout
    except subprocess.TimeoutExpired:
        return "Timeout"
    except FileNotFoundError:
        return None
    except Exception as e:
        return f"Error: {e}"

def parse_whois(whois_output):
    """Parse whois output for key information"""
    if not whois_output or whois_output == "Timeout":
        return None
    
    info = {}
    lines = whois_output.split('\n')
    
    for line in lines:
        line_lower = line.lower()
        
        if 'registrar:' in line_lower:
            info['registrar'] = line.split(':', 1)[1].strip() if ':' in line else ''
        elif 'registrant name:' in line_lower:
            info['registrant_name'] = line.split(':', 1)[1].strip() if ':' in line else ''
        elif 'registrant organization:' in line_lower:
            info['registrant_org'] = line.split(':', 1)[1].strip() if ':' in line else ''
        elif 'registrant email:' in line_lower and 'email' not in info:
            email = line.split(':', 1)[1].strip() if ':' in line else ''
            # Mask email
            if '@' in email:
                parts = email.split('@')
                if len(parts[0]) > 2:
                    masked = parts[0][:2] + '***@' + parts[1]
                else:
                    masked = '***@' + parts[1]
                info['registrant_email'] = masked
        elif 'creation date:' in line_lower:
            info['creation_date'] = line.split(':', 1)[1].strip() if ':' in line else ''
        elif 'expiry date:' in line_lower or 'expiration date:' in line_lower:
            info['expiry_date'] = line.split(':', 1)[1].strip() if ':' in line else ''
        elif 'name server:' in line_lower:
            if 'nameservers' not in info:
                info['nameservers'] = []
            ns = line.split(':', 1)[1].strip() if ':' in line else ''
            if ns:
                info['nameservers'].append(ns)
    
    return info

def main():
    print("="*60)
    print("Domain Ownership Check")
    print("="*60)
    print(f"Domain: {DOMAIN_NAME}")
    print("")
    
    # Try whois
    print("Checking WHOIS information...")
    whois_output = run_whois()
    
    if whois_output is None:
        print("❌ 'whois' command not available")
        print("   Install with: brew install whois (on macOS)")
        print("")
        print("Alternative: Run the shell script:")
        print("   ./check-domain-ownership.sh")
        sys.exit(1)
    
    if whois_output == "Timeout":
        print("⚠️  WHOIS lookup timed out")
        print("   Try running: ./check-domain-ownership.sh")
        sys.exit(1)
    
    # Parse whois
    info = parse_whois(whois_output)
    
    if info:
        print("✅ Domain Registration Information:")
        print("")
        
        if 'registrar' in info:
            print(f"Registrar: {info['registrar']}")
        
        if 'registrant_name' in info:
            print(f"Registrant Name: {info['registrant_name']}")
        
        if 'registrant_org' in info:
            print(f"Registrant Organization: {info['registrant_org']}")
        
        if 'registrant_email' in info:
            print(f"Registrant Email: {info['registrant_email']}")
            print("")
            print("⚠️  Check if this email matches yours!")
        
        if 'creation_date' in info:
            print(f"Creation Date: {info['creation_date']}")
        
        if 'expiry_date' in info:
            print(f"Expiry Date: {info['expiry_date']}")
        
        if 'nameservers' in info and info['nameservers']:
            print("")
            print("Current Nameservers:")
            for ns in info['nameservers']:
                print(f"  - {ns}")
        
        print("")
        print("="*60)
        print("Analysis")
        print("="*60)
        print("")
        
        # Check if it might be user's domain
        if 'registrant_org' in info:
            org_lower = info['registrant_org'].lower()
            if 'ffj' in org_lower or 'consulting' in org_lower:
                print("✅ Organization name suggests this might be your domain!")
            else:
                print("⚠️  Organization name doesn't match 'FFJ Consulting LLC'")
        
        if 'registrar' in info:
            print("")
            print(f"To update nameservers:")
            print(f"1. Log into {info['registrar']}")
            print(f"2. Find domain: {DOMAIN_NAME}")
            print(f"3. Update nameservers to Route 53")
    else:
        print("⚠️  Could not parse WHOIS information")
        print("")
        print("Raw WHOIS output:")
        print(whois_output[:500])
        print("...")
    
    print("")
    print("="*60)

if __name__ == "__main__":
    main()
