#!/usr/bin/env bash
set -euo pipefail

# Purpose:
# - Start ssh-agent (if needed)
# - Load ~/.ssh/id_ed25519
# - Test GitHub SSH auth (ssh -T git@github.com)
# - Optionally push a repo (defaults to current directory)
#
# Usage:
#   bash enable-github-ssh-and-push.sh
#   bash enable-github-ssh-and-push.sh /path/to/repo
#
# NOTE:
# - This script cannot add your public key to GitHub for you.
#   You must add ~/.ssh/id_ed25519.pub to GitHub account "ffjabbari"
#   under Settings -> SSH and GPG keys.

KEY="${HOME}/.ssh/id_ed25519"
PUB="${HOME}/.ssh/id_ed25519.pub"

if [[ ! -f "$KEY" || ! -f "$PUB" ]]; then
  echo "❌ Missing SSH keypair:"
  echo "  $KEY"
  echo "  $PUB"
  echo
  echo "Create one with:"
  echo "  ssh-keygen -t ed25519 -C \"your_email@example.com\""
  exit 1
fi

echo "== Starting ssh-agent (if needed) =="
if ! ssh-add -l >/dev/null 2>&1; then
  # No agent in this shell
  eval "$(ssh-agent -s)" >/dev/null
fi

echo "== Loading SSH key into agent =="
ssh-add "$KEY" >/dev/null 2>&1 || true

echo "== ssh-add -l (loaded identities) =="
ssh-add -l || true
echo

echo "== Testing GitHub SSH auth =="
set +e
SSH_TEST_OUT="$(ssh -T git@github.com 2>&1)"
SSH_TEST_CODE=$?
set -e
echo "$SSH_TEST_OUT"
echo

# GitHub often returns exit code 1 even on successful auth ("no shell access")
if echo "$SSH_TEST_OUT" | grep -qi "permission denied (publickey)"; then
  echo "❌ GitHub rejected the SSH key (publickey)."
  echo
  echo "Next step (manual, one-time):"
  echo "1) Log into GitHub as ffjabbari"
  echo "2) Go to Settings -> SSH and GPG keys -> New SSH key"
  echo "3) Paste this public key:"
  echo
  cat "$PUB"
  echo
  exit 2
fi

echo "✅ SSH looks OK (even if GitHub says 'no shell access', that's normal)."
echo

TARGET_DIR="${1:-$(pwd)}"
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "❌ Repo path not found: $TARGET_DIR"
  exit 3
fi

echo "== Attempting git push in: $TARGET_DIR =="
cd "$TARGET_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "⚠️ Not a git repo: $TARGET_DIR"
  exit 0
fi

git status -sb
echo

set +e
PUSH_OUT="$(git push origin HEAD 2>&1)"
PUSH_CODE=$?
set -e
echo "$PUSH_OUT"

if [[ $PUSH_CODE -ne 0 ]]; then
  echo
  echo "❌ Push failed. If the error mentions permissions, confirm:"
  echo "- The repo exists under the ffjabbari account"
  echo "- Your GitHub account ffjabbari has the SSH key installed"
  exit "$PUSH_CODE"
fi

echo
echo "✅ Push succeeded."

