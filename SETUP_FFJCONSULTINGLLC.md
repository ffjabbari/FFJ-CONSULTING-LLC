# Setup Guide for ffjconsultingllc.com

## Quick Start

Run this script to set up everything:

```bash
./setup-domain-ffjconsultingllc.sh
```

This script will:
1. ✅ Check domain availability
2. ✅ Create Route 53 hosted zone
3. ✅ Request SSL certificate
4. ✅ Add validation records
5. ⏳ Wait for certificate validation (5-30 minutes)

## After Certificate is Validated

Once certificate status is "ISSUED", run:

```bash
./create-cloudfront-ffjconsultingllc.sh
```

This will:
1. ✅ Create CloudFront distribution
2. ✅ Set up DNS records
3. ✅ Complete the setup

## Update Website Code

Website code has been updated with the new domain:
- ✅ `frontend/src/config.js` - Updated to `https://ffjconsultingllc.com`
- ✅ `frontend/src/content/resume.md` - Updated links
- ✅ `Docs/architecture.html` - Updated documentation

## Rebuild and Redeploy

After CloudFront is created:

```bash
cd frontend
npm run build
cd ..
aws s3 sync frontend/dist/ s3://ffj-consulting-website --delete --profile my-sso
```

## Test

After DNS propagation (5 minutes to 48 hours):
- Test: https://ffjconsultingllc.com
- Test: https://www.ffjconsultingllc.com

---

**Start with:** `./setup-domain-ffjconsultingllc.sh`
