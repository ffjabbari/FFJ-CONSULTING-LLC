# Fix Large File Push Issue

## The Problem

The image file (3MB) is still in Git history, causing HTTP 400 errors when pushing.

## Solution: Remove from Git History

Run these commands to completely remove the large file from Git history:

```bash
cd /Users/fjabbari/REPO_CURSOR/FFJ-CONSULTING-LLC

# Remove from all commits in history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch frontend/public/images/fred-picture.png' \
  --prune-empty --tag-name-filter cat -- --all

# Clean up
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Try pushing again
git push origin master --force
```

## Alternative: Increase HTTP Buffer

If the above doesn't work, increase Git's HTTP buffer:

```bash
git config http.postBuffer 524288000
git config http.maxRequestBuffer 100M
git push origin master
```

## Alternative: Use Git LFS for Large Files

If you need the image in the repo:

```bash
git lfs install
git lfs track "*.png"
git add .gitattributes
git add frontend/public/images/fred-picture.png
git commit -m "Add image with Git LFS"
git push origin master
```

## Quick Fix: Push Without Image

The image is already removed from current tracking. Try:

```bash
git config http.postBuffer 524288000
git push origin master
```
