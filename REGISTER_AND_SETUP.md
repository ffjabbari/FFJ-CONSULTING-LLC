# Register and Setup ffjconsultingllc.com

## ✅ Domain is Available!

The domain `ffjconsultingllc.com` is **AVAILABLE** and ready to register.

## Quick Setup Steps

### Step 1: Register the Domain

**Option A: Via AWS Console (Recommended - Easier)**
1. Go to: https://console.aws.amazon.com/route53/home#DomainListing:
2. Click "Register domain"
3. Search for: `ffjconsultingllc.com`
4. Add to cart and complete registration (~$12/year)
5. Wait for registration to complete (usually instant)

**Option B: Via Script (May require contact info setup)**
```bash
python3 register-ffjconsultingllc.py
```

### Step 2: Run Setup Script

After domain is registered, run:

```bash
./setup-domain-ffjconsultingllc.sh
```

This will:
- ✅ Create Route 53 hosted zone
- ✅ Request SSL certificate
- ✅ Add validation records automatically
- ⏳ Wait for certificate validation (5-30 minutes)

### Step 3: Create CloudFront

Once certificate is validated (status = "ISSUED"):

```bash
./create-cloudfront-ffjconsultingllc.sh
```

### Step 4: Rebuild and Deploy

```bash
cd frontend
npm run build
cd ..
aws s3 sync frontend/dist/ s3://ffj-consulting-website --delete --profile my-sso
```

### Step 5: Test

After DNS propagation (5 minutes to 48 hours):
- Test: https://ffjconsultingllc.com
- Test: https://www.ffjconsultingllc.com

## All Code Already Updated

✅ Website code already uses `ffjconsultingllc.com`
✅ Resume links updated
✅ Documentation updated

## Timeline

- **Domain Registration:** Instant to 24 hours (usually instant)
- **Certificate Validation:** 5-30 minutes after nameservers are set
- **CloudFront Deployment:** 15-30 minutes
- **DNS Propagation:** 5 minutes to 48 hours

---

**Start with:** Register the domain, then run `./setup-domain-ffjconsultingllc.sh`
