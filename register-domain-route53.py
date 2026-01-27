#!/usr/bin/env python3
"""
Register Domain via Route 53
This script registers ffjconsulting.com via AWS Route 53
"""

import boto3
import json
import sys
from botocore.exceptions import ClientError

DOMAIN_NAME = "ffjconsulting.com"
PROFILE = "my-sso"
REGION = "us-east-1"
HOSTED_ZONE_ID = "Z0268429M8AW2ZUY4ECU"

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

def check_domain_availability(route53domains_client):
    """Check if domain is available for registration"""
    print_header("Checking Domain Availability")
    
    try:
        response = route53domains_client.check_domain_availability(
            DomainName=DOMAIN_NAME
        )
        
        availability = response.get('Availability')
        
        if availability == 'AVAILABLE':
            print_success(f"Domain {DOMAIN_NAME} is AVAILABLE for registration")
            return True
        elif availability == 'UNAVAILABLE':
            print_error(f"Domain {DOMAIN_NAME} is UNAVAILABLE (already registered)")
            return False
        elif availability == 'RESERVED':
            print_error(f"Domain {DOMAIN_NAME} is RESERVED")
            return False
        else:
            print_info(f"Domain availability: {availability}")
            return None
    except ClientError as e:
        print_error(f"Error checking availability: {e}")
        return None

def get_domain_price(route53domains_client):
    """Get domain registration price"""
    print_header("Getting Domain Price")
    
    try:
        response = route53domains_client.list_prices(
            Tld='com'
        )
        
        # Find .com price
        for price in response.get('Prices', []):
            if price.get('Name') == 'registration':
                reg_price = price.get('Price', {})
                amount = reg_price.get('Price', 'Unknown')
                currency = reg_price.get('Currency', 'USD')
                print_info(f"Domain registration price: {currency} {amount}")
                return amount, currency
    except ClientError as e:
        print_info(f"Could not get price: {e}")
        return None, None
    
    return None, None

def check_if_already_registered(route53domains_client):
    """Check if domain is already registered in this AWS account"""
    print_header("Checking if Domain Already Registered")
    
    try:
        response = route53domains_client.list_domains()
        
        for domain in response.get('Domains', []):
            if domain['DomainName'] == DOMAIN_NAME:
                print_success(f"Domain {DOMAIN_NAME} is already registered in your AWS account")
                print_info(f"Expiration: {domain.get('Expiry', 'Unknown')}")
                return True
        
        print_info(f"Domain {DOMAIN_NAME} not found in registered domains")
        return False
    except ClientError as e:
        print_error(f"Error checking registration: {e}")
        return None

def register_domain(route53domains_client):
    """Register the domain via Route 53"""
    print_header("Registering Domain")
    
    # Get contact information (required for registration)
    # For now, we'll use a template - user may need to provide real info
    contact_info = {
        'FirstName': 'Fred',
        'LastName': 'Jabbari',
        'ContactType': 'PERSON',
        'OrganizationName': 'FFJ Consulting LLC',
        'AddressLine1': 'Your Address Line 1',
        'City': 'Your City',
        'State': 'Your State',
        'CountryCode': 'US',
        'ZipCode': 'Your ZIP',
        'PhoneNumber': '+1.1234567890',
        'Email': 'your-email@example.com'
    }
    
    print_info("Domain registration requires contact information")
    print_info("You may need to provide real contact details")
    print("")
    
    # Registration parameters
    registration_params = {
        'DomainName': DOMAIN_NAME,
        'DurationInYears': 1,
        'AutoRenew': True,
        'AdminContact': contact_info,
        'RegistrantContact': contact_info,
        'TechContact': contact_info,
        'PrivacyProtectAdminContact': False,
        'PrivacyProtectRegistrantContact': False,
        'PrivacyProtectTechContact': False
    }
    
    try:
        print_info("Attempting to register domain...")
        print_info("Note: This requires payment and may need manual approval")
        print("")
        
        response = route53domains_client.register_domain(**registration_params)
        operation_id = response.get('OperationId')
        
        print_success(f"Domain registration initiated!")
        print_info(f"Operation ID: {operation_id}")
        print("")
        print_info("Registration may take a few minutes to complete")
        print_info("Check status in AWS Console: Route 53 → Registered domains")
        
        return True, operation_id
    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', '')
        error_msg = e.response.get('Error', {}).get('Message', str(e))
        
        if error_code == 'InvalidInput':
            print_error(f"Invalid input: {error_msg}")
            print_info("You may need to provide valid contact information")
        elif error_code == 'DuplicateRequest':
            print_error("Domain registration already in progress")
        elif error_code == 'TLDRulesViolation':
            print_error(f"TLD rules violation: {error_msg}")
        else:
            print_error(f"Registration failed: {error_msg}")
        
        print("")
        print_info("Domain registration via API requires:")
        print("  1. Valid contact information")
        print("  2. Payment method on file")
        print("  3. Agreement to terms")
        print("")
        print_info("Alternative: Register via AWS Console:")
        print("  https://console.aws.amazon.com/route53/home#DomainListing:")
        
        return False, None

def update_nameservers_if_needed(route53_client, hosted_zone_id):
    """Ensure nameservers are correct"""
    print_header("Verifying Nameservers")
    
    try:
        response = route53_client.get_hosted_zone(Id=hosted_zone_id)
        nameservers = response['DelegationSet']['NameServers']
        
        print_success("Route 53 nameservers:")
        for ns in nameservers:
            print(f"   - {ns}")
        
        print("")
        print_info("If domain is registered elsewhere, update nameservers to the above")
        return nameservers
    except ClientError as e:
        print_error(f"Error getting nameservers: {e}")
        return None

def main():
    print("="*60)
    print("FFJ Consulting LLC - Domain Registration")
    print("="*60)
    print(f"Domain: {DOMAIN_NAME}")
    print(f"Profile: {PROFILE}")
    print("="*60)
    
    # Initialize AWS clients
    session = boto3.Session(profile_name=PROFILE)
    route53domains_client = session.client('route53domains', region_name='us-east-1')
    route53_client = session.client('route53', region_name=REGION)
    
    # Step 1: Check if already registered
    already_registered = check_if_already_registered(route53domains_client)
    if already_registered:
        print("\n✅ Domain is already registered!")
        print_info("Certificate validation should proceed once nameservers are set")
        nameservers = update_nameservers_if_needed(route53_client, HOSTED_ZONE_ID)
        sys.exit(0)
    
    # Step 2: Check availability
    is_available = check_domain_availability(route53domains_client)
    
    if is_available is False:
        print("\n⚠️  Domain is not available for registration")
        print_info("It may already be registered by someone else")
        print_info("Or you may need to register it via AWS Console")
        sys.exit(1)
    
    if is_available is None:
        print("\n⚠️  Could not determine availability")
        print_info("Proceeding with registration attempt...")
    
    # Step 3: Get price
    price, currency = get_domain_price(route53domains_client)
    
    # Step 4: Register domain
    print("\n" + "="*60)
    print("IMPORTANT: Domain Registration Requirements")
    print("="*60)
    print("1. Valid contact information (name, address, email, phone)")
    print("2. Payment method on file in AWS account")
    print("3. Agreement to domain registration terms")
    print("")
    
    if price:
        print(f"Estimated cost: {currency} {price} per year")
        print("")
    
    response = input("Do you want to attempt registration? (y/n): ")
    if response.lower() != 'y':
        print("\nRegistration cancelled.")
        print("You can register manually via AWS Console:")
        print("https://console.aws.amazon.com/route53/home#DomainListing:")
        sys.exit(0)
    
    success, operation_id = register_domain(route53domains_client)
    
    if success:
        print("\n" + "="*60)
        print("Registration Initiated")
        print("="*60)
        print("Next steps:")
        print("1. Check email for registration confirmation")
        print("2. Verify payment was processed")
        print("3. Wait for registration to complete (usually instant to 24 hours)")
        print("4. Once registered, certificate validation should proceed")
        print("")
        print("Check status:")
        print("  ./check-cert-and-continue.sh")
    else:
        print("\n" + "="*60)
        print("Registration via API Failed")
        print("="*60)
        print("Please register the domain manually via AWS Console:")
        print("https://console.aws.amazon.com/route53/home#DomainListing:")
        print("")
        print("After registration, update nameservers to Route 53:")
        nameservers = update_nameservers_if_needed(route53_client, HOSTED_ZONE_ID)
    
    print("\n" + "="*60)

if __name__ == "__main__":
    main()
