# Deploy to AWS - Ready to Go!

Your AWS profile `my-sso` is configured. Now run the deployment script:

## Quick Deploy

```bash
cd /Users/fjabbari/REPO_CURSOR/FFJ-CONSULTING-LLC
./deploy-aws.sh
```

This script will:
1. ✅ Build the frontend
2. ✅ Create S3 bucket (if needed)
3. ✅ Upload all files
4. ✅ Enable static website hosting
5. ✅ Configure public access
6. ✅ Give you the website URL

## What You'll Get

After deployment, you'll get a URL like:
```
http://ffj-consulting-website.s3-website-us-east-1.amazonaws.com
```

## After Deployment

Once you have the URL, share it with me and I'll:
1. Update all links in the website with your production URL
2. Update the resume markdown with the correct links
3. Update the architecture documentation

## Troubleshooting

If you get permission errors:
- Make sure your IAM user has `AmazonS3FullAccess` policy
- Or create a custom policy with S3 permissions

If the bucket name is taken:
- The script will use the existing bucket
- Or change `S3_BUCKET_NAME` in the script to something unique

Run the script and let me know the URL you get!
