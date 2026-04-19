#!/usr/bin/env bash
# ----------------------------------------
# Markdown Code Style Checker (Full Project)
#
# Checks all Markdown files in the project for style issues using markdownlint.
# Used in pre-push-check.sh
#
# Usage:
#   ./check_markdownlint_all.sh
# ----------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Collect .md files (excluding generated/vendored directories)
MD_FILES=$(find "$PROJECT_DIR" -name "*.md" \
  -not -path "*/_site/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*")

if [ -z "$MD_FILES" ]; then
  echo "No Markdown files found"
  exit 0
fi

# shellcheck disable=SC2086
markdownlint $MD_FILES
