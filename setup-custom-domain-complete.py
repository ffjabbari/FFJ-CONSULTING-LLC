#!/usr/bin/env python3
"""
Complete Custom Domain Setup for FFJ Consulting LLC
This script automates the entire process of setting up a custom domain
with Route 53, SSL, and CloudFront.
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

def print_step(step_num, description):
    print(f"\n{'='*60}")
    print(f"Step {step_num}: {description}")
    print('='*60)

def check_domain_registered(route53domains_client):
    """Check if domain is registered in AWS"""
    try:
        domains = route53domains_client.list_domains()
        for domain in domains.get('Domains', []):
            if domain['DomainName'] == DOMAIN_NAME:
                return True
        return False
    except ClientError as e:
        print(f"⚠️  Could not check domain registration: {e}")
        return None

def create_hosted_zone(route53_client):
    """Create Route 53 hosted zone"""
    try:
        # Check if hosted zone already exists
        zones = route53_client.list_hosted_zones_by_name(DNSName=f"{DOMAIN_NAME}.")
        if zones['HostedZones'] and zones['HostedZones'][0]['Name'] == f"{DOMAIN_NAME}.":
            zone_id = zones['HostedZones'][0]['Id'].split('/')[-1]
            print(f"✅ Hosted zone already exists: {zone_id}")
            return zone_id, zones['HostedZones'][0]
        
        # Create new hosted zone
        response = route53_client.create_hosted_zone(
            Name=f"{DOMAIN_NAME}.",
            CallerReference=f"ffj-consulting-{int(time.time())}"
        )
        zone_id = response['HostedZone']['Id'].split('/')[-1]
        print(f"✅ Created hosted zone: {zone_id}")
        print("\n📋 IMPORTANT: Update your domain registrar with these nameservers:")
        for ns in response['DelegationSet']['NameServers']:
            print(f"   - {ns}")
        return zone_id, response['HostedZone']
    except ClientError as e:
        print(f"❌ Error creating hosted zone: {e}")
        return None, None

def request_ssl_certificate(acm_client):
    """Request SSL certificate from ACM"""
    try:
        # Check if certificate already exists
        certs = acm_client.list_certificates()
        for cert in certs.get('CertificateSummaryList', []):
            if cert['DomainName'] == DOMAIN_NAME:
                cert_arn = cert['CertificateArn']
                # Check status
                cert_detail = acm_client.describe_certificate(CertificateArn=cert_arn)
                status = cert_detail['Certificate']['Status']
                print(f"✅ Certificate already exists: {cert_arn}")
                print(f"   Status: {status}")
                if status == 'ISSUED':
                    return cert_arn
                else:
                    print("   ⚠️  Certificate needs validation")
                    return cert_arn
        
        # Request new certificate
        response = acm_client.request_certificate(
            DomainName=DOMAIN_NAME,
            SubjectAlternativeNames=[f"www.{DOMAIN_NAME}"],
            ValidationMethod='DNS'
        )
        cert_arn = response['CertificateArn']
        print(f"✅ Certificate requested: {cert_arn}")
        print("   ⚠️  Certificate needs DNS validation")
        return cert_arn
    except ClientError as e:
        print(f"❌ Error requesting certificate: {e}")
        return None

def get_certificate_validation_records(acm_client, cert_arn):
    """Get DNS validation records for certificate"""
    try:
        cert = acm_client.describe_certificate(CertificateArn=cert_arn)
        records = []
        for option in cert['Certificate']['DomainValidationOptions']:
            if 'ResourceRecord' in option:
                records.append({
                    'Name': option['ResourceRecord']['Name'],
                    'Type': option['ResourceRecord']['Type'],
                    'Value': option['ResourceRecord']['Value']
                })
        return records
    except ClientError as e:
        print(f"❌ Error getting validation records: {e}")
        return []

def create_cloudfront_distribution(cloudfront_client, cert_arn):
    """Create CloudFront distribution"""
    try:
        s3_endpoint = f"{BUCKET_NAME}.s3-website-{REGION}.amazonaws.com"
        
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
        
        response = cloudfront_client.create_distribution(DistributionConfig=config)
        dist_id = response['Distribution']['Id']
        dist_domain = response['Distribution']['DomainName']
        print(f"✅ CloudFront distribution created: {dist_id}")
        print(f"   Domain: {dist_domain}")
        print(f"   ⚠️  Deployment takes 15-30 minutes")
        return dist_id, dist_domain
    except ClientError as e:
        print(f"❌ Error creating CloudFront distribution: {e}")
        return None, None

def create_dns_records(route53_client, zone_id, cloudfront_domain):
    """Create DNS records pointing to CloudFront"""
    try:
        # Create A record (alias) for root domain
        route53_client.change_resource_record_sets(
            HostedZoneId=zone_id,
            ChangeBatch={
                'Changes': [
                    {
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': f"{DOMAIN_NAME}.",
                            'Type': 'A',
                            'AliasTarget': {
                                'HostedZoneId': 'Z2FDTNDATAQYW2',  # CloudFront hosted zone
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
        print(f"✅ DNS records created for {DOMAIN_NAME} and www.{DOMAIN_NAME}")
        return True
    except ClientError as e:
        print(f"❌ Error creating DNS records: {e}")
        return False

def main():
    print("="*60)
    print("FFJ Consulting LLC - Custom Domain Setup")
    print("="*60)
    print(f"Domain: {DOMAIN_NAME}")
    print(f"Bucket: {BUCKET_NAME}")
    print(f"Region: {REGION}")
    print(f"Profile: {PROFILE}")
    print("="*60)
    
    # Initialize AWS clients
    session = boto3.Session(profile_name=PROFILE)
    route53_client = session.client('route53', region_name=REGION)
    acm_client = session.client('acm', region_name=REGION)
    cloudfront_client = session.client('cloudfront', region_name=REGION)
    route53domains_client = session.client('route53domains', region_name='us-east-1')
    
    # Step 1: Check domain registration
    print_step(1, "Checking Domain Registration")
    domain_registered = check_domain_registered(route53domains_client)
    if domain_registered is False:
        print(f"⚠️  Domain {DOMAIN_NAME} not found in your AWS account")
        print("   You may need to register it first.")
        print("   Go to: https://console.aws.amazon.com/route53/home#DomainListing:")
        response = input("\nContinue anyway? (y/n): ")
        if response.lower() != 'y':
            sys.exit(1)
    elif domain_registered:
        print(f"✅ Domain {DOMAIN_NAME} is registered")
    
    # Step 2: Create hosted zone
    print_step(2, "Creating Route 53 Hosted Zone")
    zone_id, zone_info = create_hosted_zone(route53_client)
    if not zone_id:
        print("❌ Failed to create hosted zone. Exiting.")
        sys.exit(1)
    
    # Step 3: Request SSL certificate
    print_step(3, "Requesting SSL Certificate")
    cert_arn = request_ssl_certificate(acm_client)
    if not cert_arn:
        print("❌ Failed to request certificate. Exiting.")
        sys.exit(1)
    
    # Get validation records
    validation_records = get_certificate_validation_records(acm_client, cert_arn)
    if validation_records:
        print("\n📋 SSL Certificate Validation Records:")
        print("   Add these CNAME records to your Route 53 hosted zone:")
        for record in validation_records:
            print(f"   Name: {record['Name']}")
            print(f"   Type: {record['Type']}")
            print(f"   Value: {record['Value']}")
            print()
    
    # Step 4: Create CloudFront distribution
    print_step(4, "Creating CloudFront Distribution")
    print("⚠️  Note: Certificate must be validated before CloudFront can use it.")
    response = input("Is the certificate validated? (y/n): ")
    if response.lower() != 'y':
        print("\n⚠️  Please validate the certificate first by adding DNS records.")
        print("   Then run this script again.")
        sys.exit(0)
    
    dist_id, dist_domain = create_cloudfront_distribution(cloudfront_client, cert_arn)
    if not dist_id:
        print("❌ Failed to create CloudFront distribution. Exiting.")
        sys.exit(1)
    
    # Step 5: Create DNS records
    print_step(5, "Creating DNS Records")
    if create_dns_records(route53_client, zone_id, dist_domain):
        print("✅ DNS records created successfully")
    
    # Summary
    print("\n" + "="*60)
    print("Setup Complete!")
    print("="*60)
    print(f"Domain: {DOMAIN_NAME}")
    print(f"Hosted Zone ID: {zone_id}")
    print(f"Certificate ARN: {cert_arn}")
    print(f"CloudFront Distribution: {dist_id}")
    print(f"CloudFront Domain: {dist_domain}")
    print("\n⚠️  Next Steps:")
    print("   1. Wait for CloudFront deployment (15-30 minutes)")
    print("   2. Update website code with new domain")
    print("   3. Rebuild and redeploy website")
    print("   4. Test https://" + DOMAIN_NAME)
    print("="*60)

if __name__ == "__main__":
    main()
