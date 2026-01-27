# How to Check AWS Console for Errors

## Quick Links

### 1. Check SSL Certificate Status (ACM)
**Direct Link:**
https://console.aws.amazon.com/acm/home?region=us-east-1#/certificates

**Steps:**
1. Click the link above (or go to AWS Console → Certificate Manager)
2. Make sure you're in **us-east-1** region (top right)
3. Find certificate for `ffjconsulting.com`
4. Click on it to see details

**What to Look For:**
- ✅ **Status:** Should show "Pending validation" (normal) or "Issued" (ready)
- ✅ **Domain name:** Should show `ffjconsulting.com` and `www.ffjconsulting.com`
- ✅ **Validation method:** Should show "DNS validation"
- ❌ **If you see errors:** Check the "Domain validation" section for error messages

**Validation Records Section:**
- Look for two CNAME records listed
- They should show the validation record names and values
- Status should be "Pending validation" (this is normal)

---

### 2. Check Route 53 DNS Records
**Direct Link:**
https://console.aws.amazon.com/route53/home#hosted-zones:

**Steps:**
1. Click the link above (or go to AWS Console → Route 53 → Hosted zones)
2. Click on `ffjconsulting.com` hosted zone
3. Look at the "Records" tab

**What to Look For:**
- ✅ Should see two CNAME records starting with `_0877cb36...` and `_b8218879...`
- ✅ These are the SSL certificate validation records
- ✅ If missing, that's the problem - run `./add-cert-validation-records.sh`

**Expected Records:**
1. `_0877cb36c30d2906888daec03e43d067.ffjconsulting.com` (CNAME)
2. `_b82188798f4ca93c4036415f9c32ee1b.www.ffjconsulting.com` (CNAME)

---

### 3. Check Route 53 Hosted Zone
**Direct Link:**
https://console.aws.amazon.com/route53/home#hosted-zones:Z0268429M8AW2ZUY4ECU

**Steps:**
1. Click the link above (goes directly to your hosted zone)
2. Check the "Records" tab
3. Verify validation records exist

**What to Check:**
- ✅ Hosted zone exists
- ✅ Nameservers are listed (4 nameservers)
- ✅ Validation CNAME records are present

---

### 4. Check CloudFront (After Certificate is Validated)
**Direct Link:**
https://console.aws.amazon.com/cloudfront/home

**Steps:**
1. Click the link above (or go to AWS Console → CloudFront)
2. Look for any distributions
3. If certificate is validated but no distribution exists, that's expected - we'll create it next

**What to Look For:**
- Currently: Should be empty (no distribution yet)
- After running `./continue-cloudfront-setup.sh`: Should show a new distribution

---

## Common Issues and Solutions

### Issue 1: Certificate Shows "Validation timed out"
**Solution:**
- Check Route 53 records exist
- Re-run: `./add-cert-validation-records.sh`
- Request a new certificate if needed

### Issue 2: Validation Records Missing in Route 53
**Solution:**
- Run: `./add-cert-validation-records.sh`
- Wait 5 minutes, then check again

### Issue 3: Certificate Status Not Changing
**Solution:**
- Verify DNS records are correct in Route 53
- Check certificate details in ACM for error messages
- Sometimes takes 30+ minutes (be patient)

### Issue 4: Can't Find Certificate in ACM
**Solution:**
- Make sure you're in **us-east-1** region
- Certificate ARN: `arn:aws:acm:us-east-1:678113404782:certificate/9ca7d55a-41cf-4441-87e0-0b5b739d6164`
- Search for `ffjconsulting.com` in the certificate list

---

## Step-by-Step: Check Everything

1. **Open ACM Console:**
   - Go to: https://console.aws.amazon.com/acm/home?region=us-east-1#/certificates
   - Find `ffjconsulting.com` certificate
   - Click on it
   - Check status and any error messages

2. **Open Route 53 Console:**
   - Go to: https://console.aws.amazon.com/route53/home#hosted-zones:Z0268429M8AW2ZUY4ECU
   - Click "Records" tab
   - Verify validation CNAME records exist

3. **If Everything Looks Good:**
   - Status is "Pending validation" = Normal, just wait
   - Status is "Issued" = Ready! Run `./check-cert-and-continue.sh`

4. **If You See Errors:**
   - Note the error message
   - Share it with me and we'll fix it

---

## Quick Status Check Command

You can also check from terminal:
```bash
./check-cert-status.sh
```

This shows the same info as the console, plus troubleshooting tips.
