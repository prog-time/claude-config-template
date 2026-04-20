#!/usr/bin/env bash
# ----------------------------------------
# Python Linter (Full Project)
#
# Checks all Python scripts in scripts/ using ruff (rules: E, F — ruff defaults).
# Config: .ruff.toml in project root.
# Used in pre-push-check.sh
#
# Usage:
#   ./check_ruff_all.sh
#
# Requires: ruff (pip install ruff)
# ----------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if ! command -v ruff &>/dev/null; then
  echo "ERROR: ruff is not installed. Install it with: pip install ruff" >&2
  exit 1
fi

PY_FILES=$(find "$PROJECT_DIR/scripts" -name "*.py" \
  -not -path "*/__pycache__/*")

if [ -z "$PY_FILES" ]; then
  echo "No Python files found in scripts/"
  exit 0
fi

# shellcheck disable=SC2086
ruff check $PY_FILES
