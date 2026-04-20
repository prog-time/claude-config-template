#!/usr/bin/env bash
# ----------------------------------------
# Secret Scanner (Full Project)
#
# Scans the repository for secrets and leaked credentials using gitleaks.
# Config: .gitleaks.toml in project root.
# Scope: entire repository history (git log) and working tree.
# Redact mode: actual secret values are masked in output.
#
# Used in pre-push-check.sh (optional — gitleaks is not required locally).
#
# Usage:
#   ./check_gitleaks_all.sh
#
# Requires: gitleaks (brew install gitleaks  OR  docker run zricethezav/gitleaks)
# Optional: if gitleaks is not installed, prints a warning and exits 0.
# ----------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if ! command -v gitleaks &>/dev/null; then
  echo "WARNING: gitleaks is not installed — secret scan skipped." >&2
  echo "  Install with: brew install gitleaks" >&2
  echo "  Or:           docker run zricethezav/gitleaks detect --source ." >&2
  exit 0
fi

cd "$PROJECT_DIR"
gitleaks detect \
  --config .gitleaks.toml \
  --redact \
  --exit-code 1
