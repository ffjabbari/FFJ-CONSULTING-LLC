#!/bin/bash
# Run this locally to: (1) sync website resume → Word .docx, (2) build & deploy to AWS.
# Usage: ./run-resume-and-deploy.sh

set -e
cd "$(dirname "$0")"

echo "=========================================="
echo "1. Sync resume (website .md → Word .docx)"
echo "=========================================="
python3 sync-resume-md-to-docx.py

echo ""
echo "=========================================="
echo "2. Build & deploy to AWS"
echo "=========================================="
./deploy-to-aws.sh

echo ""
echo "Done."
