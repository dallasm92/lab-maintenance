#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec ansible-playbook \
  -i "$ROOT_DIR/inventory.ini" \
  "$ROOT_DIR/playbooks/update.yml" \
  --diff "$@"
