#!/usr/bin/env python3
"""
Complete AWS Deployment Script for FFJ Consulting LLC
This script completes the S3 bucket configuration for public website hosting
"""

import subprocess
import sys
import json

# Configuration
S3_BUCKET_NAME = "ffj-consulting-website"
AWS_REGION = "us-east-1"
AWS_PROFILE = "my-sso"

def run_command(command, description):
    """Run an AWS CLI command and handle errors"""
    print(f"\n{'='*60}")
    print(f"Step: {description}")
    print(f"Command: {' '.join(command)}")
    print(f"{'='*60}")
    
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True
        )
        if result.stdout:
            print(f"✅ Success: {result.stdout.strip()}")
        else:
            print("✅ Success")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error: {e.stderr.strip()}")
        return False

def main():
    print("="*60)
    print("FFJ Consulting LLC - Complete AWS Deployment")
    print("="*60)
    print(f"Bucket: {S3_BUCKET_NAME}")
    print(f"Region: {AWS_REGION}")
    print(f"Profile: {AWS_PROFILE}")
    print("="*60)
    
    # Step 1: Disable Block Public Access
    command1 = [
        "aws", "s3api", "put-public-access-block",
        "--bucket", S3_BUCKET_NAME,
        "--public-access-block-configuration",
        "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false",
        "--region", AWS_REGION,
        "--profile", AWS_PROFILE
    ]
    
    if not run_command(command1, "Disable Block Public Access"):
        print("\n⚠️  Failed to disable Block Public Access. Continuing anyway...")
    
    # Step 2: Set bucket policy
    bucket_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublicReadGetObject",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": f"arn:aws:s3:::{S3_BUCKET_NAME}/*"
            }
        ]
    }
    
    # Write policy to temp file
    import tempfile
    import os
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(bucket_policy, f)
        policy_file = f.name
    
    try:
        command2 = [
            "aws", "s3api", "put-bucket-policy",
            "--bucket", S3_BUCKET_NAME,
            "--policy", f"file://{policy_file}",
            "--region", AWS_REGION,
            "--profile", AWS_PROFILE
        ]
        
        if not run_command(command2, "Set Bucket Policy for Public Access"):
            print("\n⚠️  Failed to set bucket policy. You may need to do this manually in AWS Console.")
    finally:
        # Clean up temp file
        os.unlink(policy_file)
    
    # Step 3: Verify/Enable website hosting
    command3 = [
        "aws", "s3api", "get-bucket-website",
        "--bucket", S3_BUCKET_NAME,
        "--profile", AWS_PROFILE
    ]
    
    result = subprocess.run(command3, capture_output=True, text=True)
    
    if result.returncode != 0:
        # Website hosting not configured, enable it
        print("\n" + "="*60)
        print("Enabling static website hosting...")
        print("="*60)
        
        command4 = [
            "aws", "s3", "website",
            f"s3://{S3_BUCKET_NAME}",
            "--index-document", "index.html",
            "--error-document", "index.html",
            "--profile", AWS_PROFILE
        ]
        
        run_command(command4, "Enable Static Website Hosting")
    else:
        print("\n✅ Static website hosting is already configured")
        print(result.stdout)
    
    # Final summary
    print("\n" + "="*60)
    print("✅ Deployment Configuration Complete!")
    print("="*60)
    print(f"\nYour website should be accessible at:")
    print(f"http://{S3_BUCKET_NAME}.s3-website-{AWS_REGION}.amazonaws.com")
    print("\nNext steps:")
    print("1. Test the URL above in your browser")
    print("2. Share the URL with me so I can update all links")
    print("3. I'll rebuild the site with production URLs and you can redeploy")
    print("="*60)

if __name__ == "__main__":
    main()
