#!/bin/bash

# Script to push to GitHub with increased buffer for large files

echo "Configuring Git for large file push..."
git config http.postBuffer 524288000
git config http.maxRequestBuffer 100M

echo ""
echo "Attempting to push to GitHub..."
git push origin master

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
else
    echo ""
    echo "❌ Push failed. The large file (3MB image) might still be in history."
    echo ""
    echo "Options:"
    echo "1. Use Git LFS for the image file"
    echo "2. Optimize/compress the image first"
    echo "3. Keep image out of Git (current approach - image is in dist/ when built)"
    echo ""
    echo "The image file is NOT needed in Git - it's already in your build output."
fi
