#!/usr/bin/env bash
# ----------------------------------------
# YAML Code Style Checker (Full Project)
#
# Checks all YAML files in the project for style issues using yamllint.
# Used in pre-push-check.sh
#
# Usage:
#   ./check_yamllint_all.sh
# ----------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Collect .yml/.yaml files (excluding generated/vendored directories)
YAML_FILES=$(find "$PROJECT_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) \
  -not -path "*/_site/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*")

if [ -z "$YAML_FILES" ]; then
  echo "No YAML files found"
  exit 0
fi

# shellcheck disable=SC2086
yamllint $YAML_FILES
