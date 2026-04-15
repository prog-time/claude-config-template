#!/usr/bin/env bash
# Creates the skeleton for a new skill: skills/<name>/SKILL.md + README.md
set -euo pipefail

NAME="${1:-}"
DESC="${2:-TODO: describe triggers and behaviour}"

if [[ -z "$NAME" ]]; then
  echo "usage: $0 <skill-name> [\"description\"]"
  exit 1
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$REPO/skills/$NAME"

if [[ -e "$DIR" ]]; then
  echo "skill '$NAME' already exists: $DIR"
  exit 1
fi

mkdir -p "$DIR"

cat > "$DIR/SKILL.md" <<EOF
---
name: $NAME
description: >
  $DESC
---

# $NAME

TODO: describe what the skill does, when it triggers, and what output it
produces.

## When it triggers

- TODO

## What to do

1. TODO
EOF

cat > "$DIR/README.md" <<EOF
# $NAME

$DESC

## Installation

Picked up automatically after \`make install\` at the repository root.

## Usage

TODO: example user requests.
EOF

echo "created skills/$NAME/"
echo "  - SKILL.md"
echo "  - README.md"
