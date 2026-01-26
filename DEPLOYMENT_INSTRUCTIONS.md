# AWS Deployment Instructions

## Current Status

The website is ready for deployment. Due to network connectivity issues, please deploy manually using the steps below.

## Manual Deployment Steps

### 1. Build the Frontend

```bash
cd frontend
npm run build
```

This creates a `dist/` folder with all static files.

### 2. Deploy to S3

```bash
# Create S3 bucket (if doesn't exist)
aws s3 mb s3://ffj-consulting-website --region us-east-1

# Upload files
aws s3 sync frontend/dist/ s3://ffj-consulting-website --delete

# Enable static website hosting
aws s3 website s3://ffj-consulting-website \
  --index-document index.html \
  --error-document index.html

# Make bucket public
aws s3api put-bucket-policy --bucket ffj-consulting-website --policy '{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::ffj-consulting-website/*"
  }]
}'
```

### 3. Get Your Website URL

After deployment, your website will be available at:
```
http://ffj-consulting-website.s3-website-us-east-1.amazonaws.com
```

Or if you set up CloudFront:
```
https://your-cloudfront-domain.cloudfront.net
```

### 4. Update Links with Production URL

Once you have your production URL, update:

1. **resume.md**: Update the links at the bottom with your actual URL
2. **config.js**: Set `VITE_SITE_URL` environment variable or update the default

### 5. Rebuild and Redeploy

After updating URLs:
```bash
cd frontend
npm run build
aws s3 sync dist/ s3://ffj-consulting-website --delete
```

## Links Added

The following links have been added:

1. **Resume Page**: Links to website, AI article, and GitHub
2. **Footer**: Links to resume, AI article, and GitHub
3. **Resume Markdown**: Links in the actual resume content

## Next Steps After Deployment

1. Update `Docs/architecture.html` with system architecture details
2. Test all links work with production URL
3. Set up CloudFront for HTTPS (optional but recommended)
4. Configure custom domain (optional)
