#!/usr/bin/env python3
"""
Interactive Domain Setup Script
Run this script locally - it will execute AWS commands and report results
"""

import boto3
import json
import time
import sys
from botocore.exceptions import ClientError

DOMAIN_NAME = "ffjconsulting.com"
BUCKET_NAME = "ffj-consulting-website"
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

def test_connection():
    """Test AWS connection"""
    print_header("Testing AWS Connection")
    try:
        session = boto3.Session(profile_name=PROFILE)
        sts = session.client('sts', region_name=REGION)
        identity = sts.get_caller_identity()
        print_success(f"Connected as: {identity.get('Arn', 'Unknown')}")
        return True, session
    except Exception as e:
        print_error(f"Connection failed: {e}")
        return False, None

def check_domain_registered(session):
    """Check if domain is registered"""
    print_header("Checking Domain Registration")
    try:
        route53domains = session.client('route53domains', region_name='us-east-1')
        domains = route53domains.list_domains()
        for domain in domains.get('Domains', []):
            if domain['DomainName'] == DOMAIN_NAME:
                print_success(f"Domain {DOMAIN_NAME} is registered")
                return True
        print_info(f"Domain {DOMAIN_NAME} not found in registered domains")
        print_info("You may need to register it first via AWS Console")
        return False
    except ClientError as e:
        if e.response['Error']['Code'] == 'AccessDenied':
            print_error("Access denied to Route 53 Domains")
            print_info("You may need to register the domain via AWS Console first")
        else:
            print_error(f"Error checking domain: {e}")
        return None

def create_hosted_zone(session):
    """Create Route 53 hosted zone"""
    print_header("Setting Up Route 53 Hosted Zone")
    route53 = session.client('route53', region_name=REGION)
    
    try:
        # Check if hosted zone exists
        zones = route53.list_hosted_zones_by_name(DNSName=f"{DOMAIN_NAME}.")
        if zones['HostedZones'] and zones['HostedZones'][0]['Name'] == f"{DOMAIN_NAME}.":
            zone_id = zones['HostedZones'][0]['Id'].split('/')[-1]
            print_success(f"Hosted zone already exists: {zone_id}")
            return zone_id
    except:
        pass
    
    # Create new hosted zone
    try:
        response = route53.create_hosted_zone(
            Name=f"{DOMAIN_NAME}.",
            CallerReference=f"ffj-consulting-{int(time.time())}"
        )
        zone_id = response['HostedZone']['Id'].split('/')[-1]
        print_success(f"Created hosted zone: {zone_id}")
        print("\n📋 IMPORTANT: Update your domain registrar with these nameservers:")
        for ns in response['DelegationSet']['NameServers']:
            print(f"   - {ns}")
        return zone_id
    except ClientError as e:
        print_error(f"Failed to create hosted zone: {e}")
        return None

def request_ssl_certificate(session):
    """Request SSL certificate"""
    print_header("Requesting SSL Certificate")
    acm = session.client('acm', region_name=REGION)
    
    try:
        # Check if certificate exists
        certs = acm.list_certificates()
        for cert in certs.get('CertificateSummaryList', []):
            if cert['DomainName'] == DOMAIN_NAME:
                cert_arn = cert['CertificateArn']
                cert_detail = acm.describe_certificate(CertificateArn=cert_arn)
                status = cert_detail['Certificate']['Status']
                print_success(f"Certificate exists: {cert_arn}")
                print_info(f"Status: {status}")
                if status == 'ISSUED':
                    return cert_arn
                else:
                    print_info("Certificate needs validation")
                    return cert_arn
    except:
        pass
    
    # Request new certificate
    try:
        response = acm.request_certificate(
            DomainName=DOMAIN_NAME,
            SubjectAlternativeNames=[f"www.{DOMAIN_NAME}"],
            ValidationMethod='DNS'
        )
        cert_arn = response['CertificateArn']
        print_success(f"Certificate requested: {cert_arn}")
        
        # Get validation records
        time.sleep(5)
        cert_detail = acm.describe_certificate(CertificateArn=cert_arn)
        print("\n📋 SSL Certificate Validation Records:")
        print("Add these CNAME records to your Route 53 hosted zone:")
        for option in cert_detail['Certificate']['DomainValidationOptions']:
            if 'ResourceRecord' in option:
                record = option['ResourceRecord']
                print(f"   Name: {record['Name']}")
                print(f"   Type: {record['Type']}")
                print(f"   Value: {record['Value']}")
                print()
        return cert_arn
    except ClientError as e:
        print_error(f"Failed to request certificate: {e}")
        return None

def create_cloudfront_distribution(session, cert_arn, zone_id):
    """Create CloudFront distribution"""
    print_header("Creating CloudFront Distribution")
    
    # Check certificate status
    acm = session.client('acm', region_name=REGION)
    cert_detail = acm.describe_certificate(CertificateArn=cert_arn)
    if cert_detail['Certificate']['Status'] != 'ISSUED':
        print_error("Certificate must be validated before creating CloudFront distribution")
        print_info("Please add the DNS validation records and wait for validation")
        response = input("Continue anyway? (y/n): ")
        if response.lower() != 'y':
            return None
    
    cloudfront = session.client('cloudfront', region_name=REGION)
    s3_endpoint = f"{BUCKET_NAME}.s3-website-{REGION}.amazonaws.com"
    
    try:
        config = {
            'CallerReference': f"ffj-consulting-{int(time.time())}",
            'Comment': 'FFJ Consulting LLC Website',
            'DefaultRootObject': 'index.html',
            'Origins': {
                'Quantity': 1,
                'Items': [{
                    'Id': f'S3-{BUCKET_NAME}',
                    'DomainName': s3_endpoint,
                    'CustomOriginConfig': {
                        'HTTPPort': 80,
                        'HTTPSPort': 443,
                        'OriginProtocolPolicy': 'http-only',
                        'OriginSslProtocols': {
                            'Quantity': 1,
                            'Items': ['TLSv1.2']
                        }
                    }
                }]
            },
            'DefaultCacheBehavior': {
                'TargetOriginId': f'S3-{BUCKET_NAME}',
                'ViewerProtocolPolicy': 'redirect-to-https',
                'AllowedMethods': {
                    'Quantity': 7,
                    'Items': ['GET', 'HEAD', 'OPTIONS', 'PUT', 'POST', 'PATCH', 'DELETE'],
                    'CachedMethods': {
                        'Quantity': 2,
                        'Items': ['GET', 'HEAD']
                    }
                },
                'Compress': True,
                'ForwardedValues': {
                    'QueryString': False,
                    'Cookies': {'Forward': 'none'}
                },
                'MinTTL': 0,
                'DefaultTTL': 86400,
                'MaxTTL': 31536000
            },
            'CustomErrorResponses': {
                'Quantity': 1,
                'Items': [{
                    'ErrorCode': 404,
                    'ResponsePagePath': '/index.html',
                    'ResponseCode': '200',
                    'ErrorCachingMinTTL': 300
                }]
            },
            'Enabled': True,
            'Aliases': {
                'Quantity': 2,
                'Items': [DOMAIN_NAME, f"www.{DOMAIN_NAME}"]
            },
            'ViewerCertificate': {
                'ACMCertificateArn': cert_arn,
                'SSLSupportMethod': 'sni-only',
                'MinimumProtocolVersion': 'TLSv1.2_2021'
            },
            'PriceClass': 'PriceClass_100'
        }
        
        response = cloudfront.create_distribution(DistributionConfig=config)
        dist_id = response['Distribution']['Id']
        dist_domain = response['Distribution']['DomainName']
        print_success(f"CloudFront distribution created: {dist_id}")
        print_info(f"Domain: {dist_domain}")
        print_info("Deployment takes 15-30 minutes")
        return dist_id, dist_domain
    except ClientError as e:
        print_error(f"Failed to create CloudFront distribution: {e}")
        return None, None

def create_dns_records(session, zone_id, cloudfront_domain):
    """Create DNS records"""
    print_header("Creating DNS Records")
    route53 = session.client('route53', region_name=REGION)
    
    try:
        route53.change_resource_record_sets(
            HostedZoneId=zone_id,
            ChangeBatch={
                'Changes': [
                    {
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': f"{DOMAIN_NAME}.",
                            'Type': 'A',
                            'AliasTarget': {
                                'HostedZoneId': 'Z2FDTNDATAQYW2',  # CloudFront
                                'DNSName': cloudfront_domain,
                                'EvaluateTargetHealth': False
                            }
                        }
                    },
                    {
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': f"www.{DOMAIN_NAME}.",
                            'Type': 'A',
                            'AliasTarget': {
                                'HostedZoneId': 'Z2FDTNDATAQYW2',
                                'DNSName': cloudfront_domain,
                                'EvaluateTargetHealth': False
                            }
                        }
                    }
                ]
            }
        )
        print_success(f"DNS records created for {DOMAIN_NAME} and www.{DOMAIN_NAME}")
        return True
    except ClientError as e:
        print_error(f"Failed to create DNS records: {e}")
        return False

def main():
    print("="*60)
    print("FFJ Consulting LLC - Custom Domain Setup")
    print("="*60)
    print(f"Domain: {DOMAIN_NAME}")
    print(f"Bucket: {BUCKET_NAME}")
    print(f"Profile: {PROFILE}")
    print("="*60)
    
    # Test connection
    success, session = test_connection()
    if not success:
        print("\n❌ Cannot connect to AWS. Please check your credentials and network.")
        sys.exit(1)
    
    # Check domain registration
    domain_registered = check_domain_registered(session)
    if domain_registered is False:
        print("\n⚠️  Domain not registered. You may need to register it first.")
        response = input("Continue with setup anyway? (y/n): ")
        if response.lower() != 'y':
            print("Please register the domain first via AWS Console:")
            print("https://console.aws.amazon.com/route53/home#DomainListing:")
            sys.exit(0)
    
    # Create hosted zone
    zone_id = create_hosted_zone(session)
    if not zone_id:
        print_error("Failed to create hosted zone. Exiting.")
        sys.exit(1)
    
    # Request SSL certificate
    cert_arn = request_ssl_certificate(session)
    if not cert_arn:
        print_error("Failed to request certificate. Exiting.")
        sys.exit(1)
    
    # Wait for certificate validation
    print("\n" + "="*60)
    print("IMPORTANT: Certificate Validation")
    print("="*60)
    print("Before creating CloudFront, you need to:")
    print("1. Add the DNS validation records shown above to Route 53")
    print("2. Wait 5-30 minutes for validation")
    print("3. Check certificate status in ACM console")
    response = input("\nIs the certificate validated? (y/n): ")
    if response.lower() != 'y':
        print("\nPlease validate the certificate first, then run this script again.")
        sys.exit(0)
    
    # Create CloudFront distribution
    dist_id, dist_domain = create_cloudfront_distribution(session, cert_arn, zone_id)
    if not dist_id:
        print_error("Failed to create CloudFront distribution. Exiting.")
        sys.exit(1)
    
    # Create DNS records
    if create_dns_records(session, zone_id, dist_domain):
        print_success("DNS records created")
    
    # Summary
    print_header("Setup Complete!")
    print(f"Domain: {DOMAIN_NAME}")
    print(f"Hosted Zone ID: {zone_id}")
    print(f"Certificate ARN: {cert_arn}")
    print(f"CloudFront Distribution: {dist_id}")
    print(f"CloudFront Domain: {dist_domain}")
    print("\n⚠️  Next Steps:")
    print("   1. Wait for CloudFront deployment (15-30 minutes)")
    print("   2. Tell me when ready - I'll update the website code")
    print("   3. Rebuild and redeploy website")
    print("   4. Test https://" + DOMAIN_NAME)
    print("="*60)

if __name__ == "__main__":
    main()
