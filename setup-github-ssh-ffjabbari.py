#!/usr/bin/env python3
"""
Setup GitHub SSH access for account `ffjabbari` on macOS/Linux.

What this script does (safe, local-machine only):
1) Verifies you have ~/.ssh/id_ed25519 and ~/.ssh/id_ed25519.pub
2) Prints the PUBLIC key you must add to GitHub (ffjabbari account)
3) Updates ~/.ssh/config to force github.com to use ~/.ssh/id_ed25519
   (writes a timestamped backup before changing)
4) Checks whether ssh-agent has a key loaded and prints next commands.

IMPORTANT:
- This script CANNOT add the key to GitHub for you (no credentials).
  You still paste the public key into:
  GitHub (logged in as ffjabbari) -> Settings -> SSH and GPG keys -> New SSH key

Usage:
  python3 setup-github-ssh-ffjabbari.py

Optional:
  python3 setup-github-ssh-ffjabbari.py --write-shell
    (writes a helper script ./enable-github-ssh-ffjabbari.sh you can source)
"""

from __future__ import annotations

import argparse
import datetime as _dt
import os
import shutil
import subprocess
import sys
from pathlib import Path


GITHUB_HOST = "github.com"
IDENTITY_FILE = Path.home() / ".ssh" / "id_ed25519"
PUBKEY_FILE = Path.home() / ".ssh" / "id_ed25519.pub"
SSH_CONFIG = Path.home() / ".ssh" / "config"


def run(cmd: list[str]) -> tuple[int, str]:
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return p.returncode, p.stdout.strip()


def ensure_permissions_600(path: Path) -> None:
    try:
        os.chmod(path, 0o600)
    except Exception:
        # Not fatal; just best-effort.
        pass


def backup_file(path: Path) -> Path | None:
    if not path.exists():
        return None
    ts = _dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = path.with_name(path.name + f".bak-{ts}")
    shutil.copy2(path, backup)
    return backup


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def upsert_github_host_block(config_text: str) -> str:
    """
    Add (or replace) a Host github.com block forcing IdentityFile ~/.ssh/id_ed25519.
    We keep changes minimal: if a Host github.com block exists, we replace that block.
    Otherwise we append a new block at the end.
    """
    lines = config_text.splitlines()

    def is_host_line(i: int) -> bool:
        s = lines[i].lstrip()
        return s.lower().startswith("host ")

    def host_targets(i: int) -> list[str]:
        # Host can list multiple patterns
        s = lines[i].strip()
        parts = s.split()
        return parts[1:]

    start = None
    end = None
    for i in range(len(lines)):
        if is_host_line(i):
            targets = [t.lower() for t in host_targets(i)]
            if GITHUB_HOST in targets:
                start = i
                # end is next Host line or EOF
                j = i + 1
                while j < len(lines) and not is_host_line(j):
                    j += 1
                end = j
                break

    block = [
        f"Host {GITHUB_HOST}",
        f"  HostName {GITHUB_HOST}",
        "  User git",
        f"  IdentityFile {IDENTITY_FILE}",
        "  IdentitiesOnly yes",
        "",
    ]

    if start is None:
        # Append new block.
        out = lines[:]
        if out and out[-1].strip() != "":
            out.append("")
        out.extend(block)
        return "\n".join(out).rstrip() + "\n"

    # Replace existing block.
    out = lines[:start] + block + lines[end:]
    # Normalize whitespace at end
    return "\n".join(out).rstrip() + "\n"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--write-shell", action="store_true", help="Write helper shell script")
    args = ap.parse_args()

    print("== GitHub SSH setup for ffjabbari ==")
    print(f"- Expected private key: {IDENTITY_FILE}")
    print(f"- Expected public  key: {PUBKEY_FILE}")
    print()

    if not IDENTITY_FILE.exists() or not PUBKEY_FILE.exists():
        print("❌ Missing SSH keypair.")
        print("Create one with:")
        print('  ssh-keygen -t ed25519 -C "your_email@example.com"')
        print(f"(Accept default path: {IDENTITY_FILE})")
        return 1

    ensure_permissions_600(IDENTITY_FILE)

    pubkey = read_text(PUBKEY_FILE).strip()
    print("== Step 1: Add this PUBLIC key to GitHub (ffjabbari) ==")
    print("GitHub -> Settings -> SSH and GPG keys -> New SSH key")
    print()
    print(pubkey)
    print()

    print("== Step 2: Update ~/.ssh/config to force github.com to use id_ed25519 ==")
    existing = read_text(SSH_CONFIG) if SSH_CONFIG.exists() else ""
    updated = upsert_github_host_block(existing)
    backup = backup_file(SSH_CONFIG)
    write_text(SSH_CONFIG, updated)
    ensure_permissions_600(SSH_CONFIG)
    if backup:
        print(f"✅ Updated {SSH_CONFIG} (backup: {backup})")
    else:
        print(f"✅ Created/updated {SSH_CONFIG}")
    print()

    print("== Step 3: Ensure ssh-agent is running and key is loaded ==")
    rc, out = run(["ssh-add", "-l"])
    if rc != 0 and "no identities" not in out.lower() and "could not open a connection" in out.lower():
        print("ssh-agent is not available in this shell.")
        print("Run these commands in your terminal:")
        print('  eval "$(ssh-agent -s)"')
        print(f"  ssh-add {IDENTITY_FILE}")
    else:
        # agent may exist; still advise add key
        print("Current ssh-add -l output:")
        print(out if out else "(no output)")
        print()
        print("If you do NOT see id_ed25519 listed above, run:")
        print(f"  ssh-add {IDENTITY_FILE}")
    print()

    print("== Step 4: Test and push ==")
    print("Test GitHub SSH auth:")
    print("  ssh -T git@github.com")
    print()
    print("Then push your repo:")
    print("  git push origin master")
    print()

    if args.write_shell:
        sh = Path.cwd() / "enable-github-ssh-ffjabbari.sh"
        sh_contents = f"""#!/bin/bash
set -e
eval "$(ssh-agent -s)"
ssh-add "{IDENTITY_FILE}"
ssh -T git@github.com || true
"""
        write_text(sh, sh_contents)
        os.chmod(sh, 0o755)
        print(f"✅ Wrote helper: {sh}")
        print("Run it with:")
        print(f"  source {sh}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

