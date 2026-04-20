#!/usr/bin/env bash
# ----------------------------------------
# Spell Checker (Full Project)
#
# Checks for spelling mistakes in documentation files using codespell.
# Config: .codespellrc in project root.
# Scope: skills/, agents/, docs/, README.md, README.ru.md, CONTRIBUTING.md
# Excluded: tasks/, .git/
# Used in pre-push-check.sh
#
# Usage:
#   ./check_codespell_all.sh
#
# Requires: codespell (pip install codespell)
# ----------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if ! command -v codespell &>/dev/null; then
  echo "ERROR: codespell is not installed. Install it with: pip install codespell" >&2
  exit 1
fi

# Run codespell on explicitly listed paths.
# .codespellrc in project root provides skip and ignore-words-list config.
# We cd into PROJECT_DIR so .codespellrc is picked up automatically.
cd "$PROJECT_DIR"
codespell skills/ agents/ docs/ README.md README.ru.md CONTRIBUTING.md
