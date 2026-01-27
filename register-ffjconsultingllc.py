#!/usr/bin/env python3
"""
Register ffjconsultingllc.com via Route 53
"""

import boto3
import sys
from botocore.exceptions import ClientError

DOMAIN_NAME = "ffjconsultingllc.com"
PROFILE = "my-sso"
REGION = "us-east-1"

def print_header(text):
    print("\n" + "="*60)
    print(text)
    print("="*60)

def print_success(text):
    print(f"✅ {text}")

def print_error(text):
    print(f"❌ {text}")

def print_info(text):
    print(f"ℹ️  {text}")

def main():
    print("="*60)
    print("Register Domain: ffjconsultingllc.com")
    print("="*60)
    print(f"Domain: {DOMAIN_NAME}")
    print(f"Profile: {PROFILE}")
    print("="*60)
    
    # Initialize AWS client
    try:
        session = boto3.Session(profile_name=PROFILE)
        route53domains_client = session.client('route53domains', region_name='us-east-1')
    except Exception as e:
        print_error(f"Error connecting to AWS: {e}")
        print_info("Please run this script on your machine where AWS CLI is configured.")
        sys.exit(1)
    
    # Check availability
    print_header("Checking Domain Availability")
    try:
        response = route53domains_client.check_domain_availability(
            DomainName=DOMAIN_NAME
        )
        availability = response.get('Availability')
        
        if availability == 'AVAILABLE':
            print_success(f"Domain {DOMAIN_NAME} is AVAILABLE")
        elif availability == 'UNAVAILABLE':
            print_error(f"Domain {DOMAIN_NAME} is UNAVAILABLE")
            sys.exit(1)
        else:
            print_info(f"Domain availability: {availability}")
    except ClientError as e:
        print_error(f"Error checking availability: {e}")
        sys.exit(1)
    
    # Check if already registered
    print_header("Checking if Already Registered")
    try:
        domains = route53domains_client.list_domains()
        for domain in domains.get('Domains', []):
            if domain['DomainName'] == DOMAIN_NAME:
                print_success(f"Domain {DOMAIN_NAME} is already registered in your AWS account")
                print_info(f"Expiration: {domain.get('Expiry', 'Unknown')}")
                print("\n✅ Domain is ready! Run: ./setup-domain-ffjconsultingllc.sh")
                sys.exit(0)
        
        print_info(f"Domain {DOMAIN_NAME} not found in registered domains")
    except ClientError as e:
        print_info(f"Could not check registration: {e}")
    
    # Get price
    print_header("Domain Pricing")
    try:
        response = route53domains_client.list_prices(Tld='com')
        for price in response.get('Prices', []):
            if price.get('Name') == 'registration':
                reg_price = price.get('Price', {})
                amount = reg_price.get('Price', 'Unknown')
                currency = reg_price.get('Currency', 'USD')
                print_info(f"Registration price: {currency} {amount} per year")
    except ClientError as e:
        print_info(f"Could not get price: {e}")
    
    # Registration instructions
    print_header("Domain Registration")
    print_info("Domain registration via API requires:")
    print("  1. Valid contact information")
    print("  2. Payment method on file in AWS account")
    print("  3. Agreement to registration terms")
    print("")
    print("RECOMMENDED: Register via AWS Console (easier):")
    print("  1. Go to: https://console.aws.amazon.com/route53/home#DomainListing:")
    print("  2. Click 'Register domain'")
    print("  3. Search for: ffjconsultingllc.com")
    print("  4. Add to cart and complete registration (~$12/year)")
    print("  5. Then run: ./setup-domain-ffjconsultingllc.sh")
    print("")
    
    response = input("Do you want to attempt registration via API? (y/n): ")
    if response.lower() != 'y':
        print("\n✅ Please register via AWS Console, then run: ./setup-domain-ffjconsultingllc.sh")
        sys.exit(0)
    
    # Attempt registration
    print_header("Attempting Registration")
    print_info("Note: This may fail if contact info or payment is not set up")
    
    contact_info = {
        'FirstName': 'Fred',
        'LastName': 'Jabbari',
        'ContactType': 'PERSON',
        'OrganizationName': 'FFJ Consulting LLC',
        'AddressLine1': 'Your Address',
        'City': 'Your City',
        'State': 'Your State',
        'CountryCode': 'US',
        'ZipCode': 'Your ZIP',
        'PhoneNumber': '+1.1234567890',
        'Email': 'ffjabbari@gmail.com'
    }
    
    try:
        response = route53domains_client.register_domain(
            DomainName=DOMAIN_NAME,
            DurationInYears=1,
            AutoRenew=True,
            AdminContact=contact_info,
            RegistrantContact=contact_info,
            TechContact=contact_info,
            PrivacyProtectAdminContact=False,
            PrivacyProtectRegistrantContact=False,
            PrivacyProtectTechContact=False
        )
        
        operation_id = response.get('OperationId')
        print_success(f"Domain registration initiated!")
        print_info(f"Operation ID: {operation_id}")
        print("\n✅ Registration in progress. Check AWS Console for status.")
        print("   Then run: ./setup-domain-ffjconsultingllc.sh")
        
    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', '')
        error_msg = e.response.get('Error', {}).get('Message', str(e))
        
        print_error(f"Registration failed: {error_msg}")
        print("")
        print("Please register via AWS Console instead:")
        print("  https://console.aws.amazon.com/route53/home#DomainListing:")
        print("")
        print("After registration, run: ./setup-domain-ffjconsultingllc.sh")

if __name__ == "__main__":
    main()
