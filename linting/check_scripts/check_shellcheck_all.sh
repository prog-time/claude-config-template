#!/usr/bin/env bash
# ----------------------------------------
# Shell Script Checker (Full Project)
#
# Checks all shell scripts in the project for issues using ShellCheck.
# Used in pre-push-check.sh
#
# Usage:
#   ./check_shellcheck_all.sh
# ----------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Collect .sh files (excluding generated/vendored directories)
SH_FILES=$(find "$PROJECT_DIR" -name "*.sh" \
  -not -path "*/_site/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*")

if [ -z "$SH_FILES" ]; then
  echo "No shell script files found"
  exit 0
fi

# shellcheck disable=SC2086
shellcheck $SH_FILES
