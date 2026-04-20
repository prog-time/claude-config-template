#!/usr/bin/env bash
# prepare-commit-msg hook: appends the list of staged files to the commit message.
# To activate: cp linting/prepare-commit-msg-check.sh .git/hooks/prepare-commit-msg && chmod +x .git/hooks/prepare-commit-msg

set -euo pipefail

bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preparation/add_files_in_commit_message.sh"
