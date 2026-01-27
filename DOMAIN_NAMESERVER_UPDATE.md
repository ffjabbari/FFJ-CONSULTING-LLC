# Domain Nameserver Update Guide

## The Problem

Your domain `ffjconsulting.com` is **already registered**, but the certificate can't validate because:
- The domain's nameservers are NOT pointing to Route 53
- AWS can't verify domain ownership without correct nameservers

## The Solution

Update the domain's nameservers at your registrar to point to Route 53.

## Route 53 Nameservers

Update your domain to use these nameservers:

1. `ns-140.awsdns-17.com`
2. `ns-1962.awsdns-53.co.uk`
3. `ns-1488.awsdns-58.org`
4. `ns-887.awsdns-46.net`

## How to Update Nameservers

### Step 1: Find Your Domain Registrar

The domain is registered somewhere. Common places:
- **GoDaddy**: https://www.godaddy.com
- **Namecheap**: https://www.namecheap.com
- **Google Domains**: https://domains.google
- **AWS Route 53**: https://console.aws.amazon.com/route53/home#DomainListing:
- **Other registrars**: Check your email for registration confirmation

### Step 2: Log into Your Registrar

Go to your registrar's website and log in.

### Step 3: Find DNS/Nameserver Settings

Look for:
- "DNS Management"
- "Nameservers"
- "DNS Settings"
- "Domain Settings"

### Step 4: Update Nameservers

Change from current nameservers to:
```
ns-140.awsdns-17.com
ns-1962.awsdns-53.co.uk
ns-1488.awsdns-58.org
ns-887.awsdns-46.net
```

### Step 5: Save and Wait

- Save the changes
- Wait 5-30 minutes for DNS propagation
- Certificate validation should then proceed automatically

## Check Current Nameservers

Run this script to see current nameservers:
```bash
./check-domain-nameservers.sh
```

## After Updating Nameservers

1. Wait 5-30 minutes
2. Run: `./check-cert-and-continue.sh`
3. Certificate should validate
4. CloudFront will be created automatically
5. Website will work at `https://ffjconsulting.com`

## Quick Check Commands

Check current nameservers:
```bash
dig +short NS ffjconsulting.com
```

Check if they match Route 53:
```bash
./check-domain-nameservers.sh
```

## Troubleshooting

**If you don't know where the domain is registered:**
- Check your email for registration confirmation
- Use WHOIS: `whois ffjconsulting.com` (may show registrar)
- Check common registrars you use

**If nameservers won't update:**
- Some registrars require 24-48 hours
- Contact registrar support if needed
- Verify you're logged into the correct account

---

**Once nameservers are updated, certificate validation should complete within 5-30 minutes!**
