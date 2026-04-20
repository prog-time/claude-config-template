#!/usr/bin/env bash
# Pre-push hook orchestrator.
# Run this script as .git/hooks/pre-push (see install.sh or README for setup).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "ShellCheck..."
bash "$SCRIPT_DIR/check_scripts/check_shellcheck_all.sh"
echo "----------"

echo "Markdown Code Style Checker..."
bash "$SCRIPT_DIR/check_scripts/check_markdownlint_all.sh"
echo "----------"

echo "YML/YAML Checker..."
bash "$SCRIPT_DIR/check_scripts/check_yamllint_all.sh"
echo "----------"

echo "Python Linter (ruff)..."
bash "$SCRIPT_DIR/check_scripts/check_ruff_all.sh"
echo "----------"

echo "Shell Formatter (shfmt)..."
bash "$SCRIPT_DIR/check_scripts/check_shfmt_all.sh"
echo "----------"

echo "Spell Checker (codespell)..."
bash "$SCRIPT_DIR/check_scripts/check_codespell_all.sh"
echo "----------"

# Optional checks — only run if the scripts are present
script="$SCRIPT_DIR/check_scripts/check_htmlhint_all.sh"
if [ -f "$script" ]; then
  echo "HTML Code Checker..."
  bash "$script"
  echo "----------"
fi

script="$SCRIPT_DIR/check_scripts/check_stylelint_all.sh"
if [ -f "$script" ]; then
  echo "CSS Code Style Checker..."
  bash "$script"
  echo "----------"
fi

# Secret scanner — optional (gitleaks may not be installed locally).
# If gitleaks is not installed, check_gitleaks_all.sh prints a warning and exits 0.
script="$SCRIPT_DIR/check_scripts/check_gitleaks_all.sh"
if [ -f "$script" ]; then
  echo "Secret Scanner (gitleaks)..."
  bash "$script"
  echo "----------"
fi

echo "JSON Validator..."
bash "$SCRIPT_DIR/check_scripts/check_json_validate_all.sh"
echo "----------"
