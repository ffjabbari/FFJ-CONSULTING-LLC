#!/usr/bin/env python3
"""
Complete AWS Deployment Script for FFJ Consulting LLC
This script builds the frontend, deploys to S3, fixes content-types, and invalidates CloudFront cache.
"""

import subprocess
import sys
import os
import json
import boto3
from botocore.exceptions import ClientError

# Configuration
BUCKET_NAME = "ffj-consulting-website"
AWS_REGION = "us-east-1"
AWS_PROFILE = "my-sso"
CLOUDFRONT_DIST_ID = "E3545N3N8YO2FZ"
FRONTEND_DIR = "frontend"
DIST_DIR = os.path.join(FRONTEND_DIR, "dist")

def print_step(step_num, description):
    """Print a formatted step header"""
    print(f"\n{'='*60}")
    print(f"Step {step_num}: {description}")
    print('='*60)

def run_command(command, description, check=True):
    """Run a shell command and handle errors"""
    print(f"\nRunning: {' '.join(command) if isinstance(command, list) else command}")
    try:
        result = subprocess.run(
            command,
            shell=isinstance(command, str),
            capture_output=True,
            text=True,
            check=check
        )
        if result.stdout:
            print(result.stdout)
        return result.returncode == 0
    except subprocess.CalledProcessError as e:
        print(f"❌ Error: {e.stderr}")
        return False

def build_frontend():
    """Build the React frontend"""
    print_step(1, "Building Frontend")
    
    if not os.path.exists(FRONTEND_DIR):
        print(f"❌ Frontend directory not found: {FRONTEND_DIR}")
        return False
    
    os.chdir(FRONTEND_DIR)
    success = run_command(["npm", "run", "build"], "Building frontend")
    os.chdir("..")
    
    if not success:
        print("❌ Build failed")
        return False
    
    if not os.path.exists(DIST_DIR):
        print(f"❌ Build output not found: {DIST_DIR}")
        return False
    
    print("✅ Build successful")
    return True

def get_js_file():
    """Find the JavaScript file in the dist directory"""
    assets_dir = os.path.join(DIST_DIR, "assets")
    if not os.path.exists(assets_dir):
        return None
    
    for file in os.listdir(assets_dir):
        if file.endswith(".js"):
            return os.path.join("assets", file)
    return None

def deploy_to_s3():
    """Deploy files to S3 with correct content-types"""
    print_step(2, "Deploying to S3")
    
    try:
        session = boto3.Session(profile_name=AWS_PROFILE)
        s3 = session.client('s3', region_name=AWS_REGION)
        
        # Upload all files first
        print("\nUploading all files to S3...")
        result = subprocess.run(
            ["aws", "s3", "sync", DIST_DIR, f"s3://{BUCKET_NAME}",
             "--delete", "--profile", AWS_PROFILE, "--region", AWS_REGION],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            print(f"❌ Upload failed: {result.stderr}")
            return False
        
        print(result.stdout)
        
        # Fix JavaScript file content-type
        js_file = get_js_file()
        if js_file:
            js_key = js_file
            print(f"\nFixing content-type for: {js_key}")
            
            # Copy object with new content-type
            copy_source = {
                'Bucket': BUCKET_NAME,
                'Key': js_key
            }
            
            s3.copy_object(
                CopySource=copy_source,
                Bucket=BUCKET_NAME,
                Key=js_key,
                ContentType='application/javascript',
                MetadataDirective='REPLACE'
            )
            print("✅ JavaScript content-type set to application/javascript")
        
        # Fix HTML content-type
        html_key = "index.html"
        if os.path.exists(os.path.join(DIST_DIR, html_key)):
            print(f"\nFixing content-type for: {html_key}")
            copy_source = {
                'Bucket': BUCKET_NAME,
                'Key': html_key
            }
            s3.copy_object(
                CopySource=copy_source,
                Bucket=BUCKET_NAME,
                Key=html_key,
                ContentType='text/html',
                CacheControl='no-cache',
                MetadataDirective='REPLACE'
            )
            print("✅ HTML content-type set to text/html")
        
        # Fix CSS content-type
        assets_dir = os.path.join(DIST_DIR, "assets")
        if os.path.exists(assets_dir):
            for file in os.listdir(assets_dir):
                if file.endswith(".css"):
                    css_key = os.path.join("assets", file)
                    print(f"\nFixing content-type for: {css_key}")
                    copy_source = {
                        'Bucket': BUCKET_NAME,
                        'Key': css_key
                    }
                    s3.copy_object(
                        CopySource=copy_source,
                        Bucket=BUCKET_NAME,
                        Key=css_key,
                        ContentType='text/css',
                        CacheControl='public, max-age=31536000, immutable',
                        MetadataDirective='REPLACE'
                    )
                    print("✅ CSS content-type set to text/css")
        
        print("\n✅ All files uploaded to S3 with correct content-types")
        return True
        
    except ClientError as e:
        print(f"❌ AWS Error: {e}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def invalidate_cloudfront():
    """Invalidate CloudFront cache"""
    print_step(3, "Invalidating CloudFront Cache")
    
    try:
        session = boto3.Session(profile_name=AWS_PROFILE)
        cloudfront = session.client('cloudfront', region_name=AWS_REGION)
        
        response = cloudfront.create_invalidation(
            DistributionId=CLOUDFRONT_DIST_ID,
            InvalidationBatch={
                'Paths': {
                    'Quantity': 1,
                    'Items': ['/*']
                },
                'CallerReference': f"deploy-{int(__import__('time').time())}"
            }
        )
        
        invalidation_id = response['Invalidation']['Id']
        print(f"✅ CloudFront cache invalidation created: {invalidation_id}")
        print("   Cache invalidation takes 1-5 minutes to complete")
        return True
        
    except ClientError as e:
        print(f"❌ Failed to create cache invalidation: {e}")
        return False

def main():
    print("="*60)
    print("FFJ Consulting LLC - Complete Deployment")
    print("="*60)
    print(f"Bucket: {BUCKET_NAME}")
    print(f"Region: {AWS_REGION}")
    print(f"Profile: {AWS_PROFILE}")
    print(f"CloudFront Distribution: {CLOUDFRONT_DIST_ID}")
    print("="*60)
    
    # Step 1: Build frontend
    if not build_frontend():
        print("\n❌ Deployment failed at build step")
        sys.exit(1)
    
    # Step 2: Deploy to S3
    if not deploy_to_s3():
        print("\n❌ Deployment failed at S3 upload step")
        sys.exit(1)
    
    # Step 3: Invalidate CloudFront
    if not invalidate_cloudfront():
        print("\n⚠️  Deployment succeeded but cache invalidation failed")
        print("   You may need to invalidate cache manually in AWS Console")
    
    # Summary
    print("\n" + "="*60)
    print("✅ Deployment Complete!")
    print("="*60)
    print(f"\nYour website is deployed at:")
    print(f"  https://ffjconsultingllc.com")
    print(f"  https://www.ffjconsultingllc.com")
    print("\n⚠️  Next Steps:")
    print("  1. Wait 1-5 minutes for cache invalidation")
    print("  2. Hard refresh your browser (Cmd+Shift+R)")
    print("  3. Test the URLs above")
    print("="*60)

if __name__ == "__main__":
    main()
