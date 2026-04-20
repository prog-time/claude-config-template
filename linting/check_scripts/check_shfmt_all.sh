#!/usr/bin/env bash
# ----------------------------------------
# Shell Script Formatter Check (Full Project)
#
# Checks shell script formatting using shfmt.
# Indent style: 2 spaces (-i 2), case indent (-ci).
# Determined by surveying existing scripts in this repo (2-space indent dominates).
#
# Scope: linting/**/*.sh only.
# Baseline suppressions: install.sh and scripts/*.sh are excluded because they contain
# pre-existing formatting violations. Follow-up task required to reformat those files.
#
# Used in pre-push-check.sh
#
# Usage:
#   ./check_shfmt_all.sh
#
# Requires: shfmt (brew install shfmt  OR  go install mvdan.cc/sh/v3/cmd/shfmt@latest
#                  OR  curl binary download from https://github.com/mvdan/sh/releases)
# ----------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if ! command -v shfmt &>/dev/null; then
  echo "ERROR: shfmt is not installed." >&2
  echo "  Install with: brew install shfmt" >&2
  echo "  Or:           go install mvdan.cc/sh/v3/cmd/shfmt@latest" >&2
  echo "  Or: curl binary from https://github.com/mvdan/sh/releases" >&2
  exit 1
fi

# Collect shell scripts in scope.
# Baseline: linting/check_scripts/*.sh and linting/*.sh (pre-push-check, prepare-commit-msg).
# Excluded from baseline (pre-existing violations, tracked in follow-up tasks):
#   - install.sh
#   - scripts/*.sh
#   - linting/preparation/*.sh (add_files_in_commit_message.sh: space-around-> violation)
SH_FILES=$(find "$PROJECT_DIR/linting" -name "*.sh" \
  -not -path "*/preparation/*" \
  -not -path "*/_site/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*")

if [ -z "$SH_FILES" ]; then
  echo "No shell script files found in linting/"
  exit 0
fi

# shellcheck disable=SC2086
shfmt -d -i 2 -ci $SH_FILES
