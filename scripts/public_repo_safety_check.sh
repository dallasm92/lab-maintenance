#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[check] scanning for private addressing in tracked files"
if rg -n --hidden --glob '!.git' '(192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' "$ROOT"; then
  echo "[fail] private addressing found"
  exit 1
fi

echo "[check] scanning for secrets in tracked files"
if rg -n --hidden --glob '!.git' '(BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|ghp_[A-Za-z0-9]{30,}|AKIA[0-9A-Z]{16}|api[_-]?key|secret\s*[:=]|token\s*[:=]|password\s*[:=])' "$ROOT"; then
  echo "[fail] potential secret-like content found"
  exit 1
fi

echo "[ok] no obvious private IPs or secret-like patterns found"
