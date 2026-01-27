# Domain Update Summary

## ✅ Code Updates Completed

All website code has been updated to use the new custom domain: **https://ffjconsulting.com**

### Files Updated:

1. **frontend/src/config.js**
   - Changed `SITE_URL` from `http://ffj-consulting-website.s3-website-us-east-1.amazonaws.com` to `https://ffjconsulting.com`

2. **frontend/src/content/resume.md**
   - Updated all website links to use `https://ffjconsulting.com`
   - Updated article links to use the new domain

3. **Docs/architecture.html**
   - Updated production URL references
   - Added custom domain documentation
   - Updated all links in "Links and Resources" section

## ⏳ Waiting For

1. **SSL Certificate Validation** - Currently `PENDING_VALIDATION`
   - DNS validation records have been added to Route 53
   - Should validate within 5-30 minutes

2. **CloudFront Distribution** - Will be created after certificate validation

3. **Domain Registration** - Domain `ffjconsulting.com` needs to be registered
   - If not registered yet, register via AWS Route 53 Console
   - Update nameservers at registrar to Route 53 nameservers

## 📋 Next Steps

1. **Check certificate status:**
   ```bash
   ./check-cert-and-continue.sh
   ```
   This will automatically create CloudFront when certificate is validated.

2. **After CloudFront is created:**
   - Rebuild the website: `cd frontend && npm run build`
   - Redeploy to S3: `aws s3 sync frontend/dist/ s3://ffj-consulting-website --delete --profile my-sso`

3. **Update domain nameservers** (if domain registered externally):
   - Use these Route 53 nameservers:
     - ns-140.awsdns-17.com
     - ns-1962.awsdns-53.co.uk
     - ns-1488.awsdns-58.org
     - ns-887.awsdns-46.net

4. **Test the domain:**
   - Wait for DNS propagation (5 minutes to 48 hours)
   - Test: https://ffjconsulting.com
   - Test: https://www.ffjconsulting.com

## 🔧 Current Configuration

- **Domain:** ffjconsulting.com
- **Hosted Zone ID:** Z0268429M8AW2ZUY4ECU
- **Certificate ARN:** arn:aws:acm:us-east-1:678113404782:certificate/9ca7d55a-41cf-4441-87e0-0b5b739d6164
- **Certificate Status:** PENDING_VALIDATION
- **S3 Bucket:** ffj-consulting-website
