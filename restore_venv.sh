#!/usr/bin/env bash
set -euo pipefail

DRYRUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRYRUN=1
fi

VENV="${HOME}/cyber-env"
REQS="requirements.txt"

# Check if requirements.txt exists and is non-empty
if [[ ! -s "$REQS" ]]; then
  echo "❌ Error: $REQS is missing or empty."
  exit 1
fi

# Count how many packages are listed
PKG_COUNT=$(grep -cve '^\s*#' -e '^\s*$' "$REQS")

if [[ $DRYRUN -eq 1 ]]; then
  echo "[DRY RUN] Would create venv at ${VENV}"
  echo "[DRY RUN] Would install the following packages:"
  cat "$REQS"
  echo "[DRY RUN] ($PKG_COUNT packages total)"
else
  python3 -m venv "${VENV}"
  source "${VENV}/bin/activate"
  python -m pip install --upgrade pip
  pip install -r "$REQS"
  echo "✅ Venv restored at ${VENV} ($PKG_COUNT packages installed)"
fi
