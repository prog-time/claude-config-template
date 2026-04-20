#!/usr/bin/env bash
# Creates/removes symlinks from the repository into ~/.claude/.
# Safe: only touches what exists in the repo. Anthropic built-in skills are left alone.

set -euo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--dry-run] [--uninstall]

  --dry-run     show actions without making changes
  --uninstall   remove previously created symlinks
EOF
      exit 0
      ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

# Categories that we symlink entry-by-entry (not the whole folder, to avoid clashing with built-ins)
CATEGORIES=(skills agents commands hooks)

log() { printf "%s\n" "$*"; }
run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    log "DRY: $*"
  else
    "$@"
  fi
}

ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    run mkdir -p "$dir"
  fi
}

link_one() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      log "  = $dst (already linked)"
      return
    fi
    log "  ! $dst is a symlink, but points to '$current'. Skipping."
    return
  fi
  if [[ -e "$dst" ]]; then
    log "  ! $dst exists and is not a symlink. Skipping."
    return
  fi
  run ln -s "$src" "$dst"
  log "  + $dst -> $src"
}

unlink_one() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      run rm "$dst"
      log "  - $dst"
      return
    fi
  fi
  log "  · $dst skipped (not our symlink)"
}

process_category() {
  local cat="$1"
  local src_root="$REPO/$cat"
  local dst_root="$CLAUDE_HOME/$cat"

  if [[ ! -d "$src_root" ]]; then
    return
  fi

  ensure_dir "$dst_root"
  log "[$cat]"

  shopt -s nullglob
  for entry in "$src_root"/*; do
    local name
    name="$(basename "$entry")"
    local src="$src_root/$name"
    local dst="$dst_root/$name"
    if [[ $UNINSTALL -eq 1 ]]; then
      unlink_one "$src" "$dst"
    else
      link_one "$src" "$dst"
    fi
  done
  shopt -u nullglob
}

log "claude-config: $REPO"
log "target:        $CLAUDE_HOME"
[[ $DRY_RUN -eq 1 ]] && log "(dry-run)"
[[ $UNINSTALL -eq 1 ]] && log "(uninstall)"
log ""

for cat in "${CATEGORIES[@]}"; do
  process_category "$cat"
done

log ""
log "Done."

# ---------------------------------------------------------------------------
# Pre-push hook installation (optional)
# ---------------------------------------------------------------------------
GIT_HOOKS_DIR="$REPO/.git/hooks"
PRE_PUSH_SRC="$REPO/linting/pre-push-check.sh"
PRE_PUSH_DST="$GIT_HOOKS_DIR/pre-push"

if [[ $UNINSTALL -eq 1 ]]; then
  if [[ -L "$PRE_PUSH_DST" ]]; then
    _current="$(readlink "$PRE_PUSH_DST")"
    if [[ "$_current" == "$PRE_PUSH_SRC" ]]; then
      run rm "$PRE_PUSH_DST"
      log "[hooks] - pre-push symlink removed"
    fi
  fi
else
  if [[ -f "$PRE_PUSH_SRC" ]] && [[ -d "$GIT_HOOKS_DIR" ]]; then
    log "[hooks]"
    link_one "$PRE_PUSH_SRC" "$PRE_PUSH_DST"
  fi
fi

# Remind the user to update LICENSE if it still contains the template placeholder name.
if [[ $UNINSTALL -eq 0 ]] && grep -q "TODO (after fork)" "$REPO/LICENSE" 2>/dev/null; then
  log ""
  log "REMINDER: update LICENSE — replace the author name and year in the Copyright line."
fi
