#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <host_or_group_limit> [extra ansible args...]"
  echo "Example: $0 macmint --check"
  echo "Example: $0 ubuntu_servers -e baseline_enforce_timers=true"
  exit 1
fi

LIMIT="$1"
shift

exec ansible-playbook \
  -i "$ROOT_DIR/inventory.ini" \
  "$ROOT_DIR/playbooks/baseline.yml" \
  --limit "$LIMIT" \
  --tags validate,enforce \
  --diff \
  "$@"
