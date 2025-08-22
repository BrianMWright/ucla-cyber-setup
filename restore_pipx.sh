#!/usr/bin/env bash
set -euo pipefail

DRYRUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRYRUN=1
fi

LIST_FILE="pipx-packages.txt"

# Ensure list exists and is non-empty (after stripping comments/blank lines)
if [[ ! -f "$LIST_FILE" ]]; then
  echo "❌ Error: $LIST_FILE not found."
  exit 1
fi
PKG_COUNT=$(grep -cve '^\s*#' -e '^\s*$' "$LIST_FILE")
if [[ "$PKG_COUNT" -eq 0 ]]; then
  echo "❌ Error: $LIST_FILE contains no packages."
  exit 1
fi

# Ensure pipx available
if ! command -v pipx >/dev/null 2>&1; then
  echo "Installing pipx..."
  sudo apt update && sudo apt install -y pipx
  pipx ensurepath
fi

# Reload PATH for current shell (first-run convenience)
export PATH="$HOME/.local/bin:$PATH"

processed=0
while IFS= read -r raw; do
  # skip blanks/comments
  [[ -z "$raw" || "$raw" =~ ^[[:space:]]*# ]] && continue

  # first token is the package name; allow "name 1.2.3" lines
  pkg=$(awk '{print $1}' <<<"$raw")

  if [[ $DRYRUN -eq 1 ]]; then
    echo "[DRY RUN] Would install ${raw} via pipx"
  else
    echo "Installing ${raw} via pipx..."
    # If version is present, pipx install "name==version"; else just name
    if [[ "$raw" =~ ^([[:alnum:]-_\.]+)[[:space:]]+([0-9]+\.[0-9]+(\.[0-9]+)?)$ ]]; then
      name="${BASH_REMATCH[1]}"; ver="${BASH_REMATCH[2]}"
      pipx install "${name}==${ver}" || echo "Note: ${name} may already be installed."
    else
      pipx install "$pkg" || echo "Note: ${pkg} may already be installed."
    fi
  fi
  ((processed++))
done < "$LIST_FILE"

if [[ $DRYRUN -eq 1 ]]; then
  echo "[DRY RUN] (${processed} apps total)"
else
  echo "✅ pipx apps processed (${processed} installed/checked)"
fi
