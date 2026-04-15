#!/usr/bin/env bash
# scripts/doctor.sh — read-only installation health check.
# Checks symlinks, CLI tools, MCP config, frontmatter lint, and Python version.
# Output: one line per check prefixed with [OK], [WARN], or [FAIL].
# Exit code: 0 if no FAIL checks; 1 if at least one FAIL.

set -euo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FAIL_COUNT=0

ok()   { printf "[OK]   %s\n" "$*"; }
warn() { printf "[WARN] %s\n" "$*"; }
fail() { printf "[FAIL] %s\n" "$*"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

echo "claude-config doctor — $REPO"
echo "target: $CLAUDE_HOME"
echo ""

# ---------------------------------------------------------------------------
# 1. Python version (required >= 3.12)
# ---------------------------------------------------------------------------
if command -v python3 &>/dev/null; then
  PY_VERSION="$(python3 --version 2>&1 | awk '{print $2}')"
  PY_MAJOR="$(echo "$PY_VERSION" | cut -d. -f1)"
  PY_MINOR="$(echo "$PY_VERSION" | cut -d. -f2)"
  if [[ "$PY_MAJOR" -gt 3 ]] || { [[ "$PY_MAJOR" -eq 3 ]] && [[ "$PY_MINOR" -ge 12 ]]; }; then
    ok "Python $PY_VERSION"
  else
    warn "Python $PY_VERSION — 3.12+ required for lint_skills.py"
  fi
else
  fail "python3 not found"
fi

# ---------------------------------------------------------------------------
# 2. Claude CLI
# ---------------------------------------------------------------------------
if command -v claude &>/dev/null; then
  CLAUDE_VER="$(claude --version 2>&1 | head -1)"
  ok "claude: $CLAUDE_VER"
else
  warn "claude CLI not found — install from https://claude.ai/download"
fi

# ---------------------------------------------------------------------------
# 3. gh CLI (optional)
# ---------------------------------------------------------------------------
if command -v gh &>/dev/null; then
  GH_VER="$(gh --version 2>&1 | head -1)"
  ok "gh: $GH_VER"
else
  warn "gh CLI not found — optional, useful for GitHub-integrated skills"
fi

# ---------------------------------------------------------------------------
# 4. Symlinks in ~/.claude/
# ---------------------------------------------------------------------------
CATEGORIES=(skills agents commands hooks)
for cat in "${CATEGORIES[@]}"; do
  src_root="$REPO/$cat"
  dst_root="$CLAUDE_HOME/$cat"
  [[ -d "$src_root" ]] || continue
  shopt -s nullglob
  for entry in "$src_root"/*; do
    name="$(basename "$entry")"
    dst="$dst_root/$name"
    if [[ -L "$dst" ]]; then
      target="$(readlink "$dst")"
      if [[ "$target" == "$entry" ]]; then
        ok "symlink $cat/$name"
      else
        warn "symlink $cat/$name points to '$target' (expected '$entry')"
      fi
    elif [[ -e "$dst" ]]; then
      warn "$dst exists but is not a symlink — run 'make install' to review"
    else
      fail "missing symlink $cat/$name — run 'make install'"
    fi
  done
  shopt -u nullglob
done

# ---------------------------------------------------------------------------
# 5. MCP server config
# ---------------------------------------------------------------------------
MCP_CONFIG="$CLAUDE_HOME/mcp/servers.json"
if [[ -f "$MCP_CONFIG" ]]; then
  if command -v python3 &>/dev/null; then
    SERVERS="$(python3 -c "
import json, sys
try:
    d = json.load(open('$MCP_CONFIG'))
    names = list(d.get('mcpServers', {}).keys())
    print(', '.join(names) if names else '(empty)')
except Exception as e:
    print('parse error: ' + str(e), file=sys.stderr)
    sys.exit(1)
" 2>&1)"
    ok "MCP config found — servers: $SERVERS"
  else
    ok "MCP config found (python3 unavailable, skipping server list)"
  fi
else
  warn "MCP config not found at $MCP_CONFIG — copy mcp/servers.json.example to activate"
fi

# ---------------------------------------------------------------------------
# 6. Frontmatter lint
# ---------------------------------------------------------------------------
LINT_SCRIPT="$REPO/scripts/lint_skills.py"
if [[ -f "$LINT_SCRIPT" ]] && command -v python3 &>/dev/null; then
  if python3 "$LINT_SCRIPT" > /dev/null 2>&1; then
    ok "frontmatter lint passed"
  else
    fail "frontmatter lint failed — run 'make lint' for details"
  fi
else
  warn "lint_skills.py or python3 not available — skipping frontmatter check"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
if [[ "$FAIL_COUNT" -eq 0 ]]; then
  echo "All checks passed ($FAIL_COUNT failures)."
  exit 0
else
  echo "$FAIL_COUNT check(s) failed."
  exit 1
fi
