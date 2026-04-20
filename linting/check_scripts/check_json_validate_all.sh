#!/usr/bin/env bash
# ----------------------------------------
# JSON Validator (Full Project)
#
# Validates JSON files in two stages:
#   1. Syntax check — all JSON files using python -m json.tool
#   2. Schema check — .claude/settings*.json validated against
#      https://json.schemastore.org/claude-code-settings.json
#      (requires: pip install jsonschema requests)
#
# Files without a public schema (mcp/servers.json.example, etc.)
# are checked for syntax only.
#
# Used in pre-push-check.sh (mandatory — always runs).
#
# Usage:
#   ./check_json_validate_all.sh
#
# Requires: python3 (built-in), jsonschema (pip install jsonschema)
# ----------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

ERROR_FOUND=0

# ---------------------------------------------------------------------------
# Stage 1 — Syntax check for all tracked JSON files
# ---------------------------------------------------------------------------

echo "Stage 1: JSON syntax check..."

# Collect JSON files: mcp/*.json*, .claude/settings*.json (if present and tracked)
JSON_FILES=()

# mcp/ example files
while IFS= read -r -d '' f; do
  JSON_FILES+=("$f")
done < <(find "$PROJECT_DIR/mcp" -name "*.json" -o -name "*.json.*" -o -name "*.example" |
  grep -E '\.(json|example)$' |
  tr '\n' '\0' |
  xargs -0 -I{} sh -c 'test -f "{}" && echo "{}"' |
  tr '\n' '\0')

# .claude/settings*.json — only if they exist (settings.local.json is gitignored
# but may be present locally; validate if found)
while IFS= read -r -d '' f; do
  JSON_FILES+=("$f")
done < <(find "$PROJECT_DIR/.claude" -maxdepth 1 -name "settings*.json" -print0 2>/dev/null || true)

if [ ${#JSON_FILES[@]} -eq 0 ]; then
  echo "No JSON files found to validate."
else
  for file in "${JSON_FILES[@]}"; do
    rel="${file#"$PROJECT_DIR/"}"
    echo "  Syntax: $rel"
    if ! python3 -m json.tool "$file" >/dev/null 2>&1; then
      # Re-run without redirect to show the parse error with position
      python3 -m json.tool "$file" || true
      echo "ERROR: JSON syntax error in $rel" >&2
      ERROR_FOUND=1
    fi
  done
fi

# ---------------------------------------------------------------------------
# Stage 2 — Schema validation for .claude/settings*.json
# ---------------------------------------------------------------------------

echo "Stage 2: JSON schema validation for .claude/settings*.json..."

SCHEMA_FILES=()
while IFS= read -r -d '' f; do
  SCHEMA_FILES+=("$f")
done < <(find "$PROJECT_DIR/.claude" -maxdepth 1 -name "settings*.json" -print0 2>/dev/null || true)

if [ ${#SCHEMA_FILES[@]} -eq 0 ]; then
  echo "  No .claude/settings*.json found — schema validation skipped."
else
  if ! python3 -c "import jsonschema, urllib.request" 2>/dev/null; then
    echo "WARNING: jsonschema not installed — schema validation skipped." >&2
    echo "  Install with: pip install jsonschema" >&2
  else
    SCHEMA_URL="https://json.schemastore.org/claude-code-settings.json"
    SCHEMA_CACHE="$PROJECT_DIR/.claude/logs/.schema-cache-claude-code-settings.json"

    # Download schema if not cached (cache is ephemeral — not committed)
    if [ ! -f "$SCHEMA_CACHE" ]; then
      mkdir -p "$(dirname "$SCHEMA_CACHE")"
      echo "  Downloading schema from $SCHEMA_URL..."
      python3 -c "
import urllib.request, sys
try:
    urllib.request.urlretrieve('$SCHEMA_URL', '$SCHEMA_CACHE')
except Exception as e:
    print(f'WARNING: Could not download schema: {e}', file=sys.stderr)
    sys.exit(2)
" || {
        echo "WARNING: Schema download failed — schema validation skipped." >&2
        SCHEMA_FILES=()
      }
    fi

    for file in "${SCHEMA_FILES[@]}"; do
      rel="${file#"$PROJECT_DIR/"}"
      echo "  Schema: $rel"
      if ! python3 - "$file" "$SCHEMA_CACHE" <<'PYEOF'; then
import json, sys, pathlib
try:
    import jsonschema
except ImportError:
    print("WARNING: jsonschema not installed", file=sys.stderr)
    sys.exit(0)

instance_path, schema_path = sys.argv[1], sys.argv[2]
try:
    instance = json.loads(pathlib.Path(instance_path).read_text())
    schema = json.loads(pathlib.Path(schema_path).read_text())
    jsonschema.validate(instance=instance, schema=schema)
except json.JSONDecodeError as e:
    print(f"JSON parse error in {instance_path}: {e}", file=sys.stderr)
    sys.exit(1)
except jsonschema.ValidationError as e:
    print(f"Schema validation error in {instance_path}:", file=sys.stderr)
    print(f"  Path: {' -> '.join(str(p) for p in e.absolute_path)}", file=sys.stderr)
    print(f"  Message: {e.message}", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"WARNING: Schema validation skipped ({e})", file=sys.stderr)
    sys.exit(0)
PYEOF
        ERROR_FOUND=1
      fi
    done
  fi
fi

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------

if [ "$ERROR_FOUND" -eq 0 ]; then
  echo "All JSON files passed validation."
else
  echo "JSON validation found errors." >&2
  exit 1
fi
