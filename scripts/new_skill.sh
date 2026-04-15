#!/usr/bin/env bash
# Создаёт скелет нового скила: skills/<name>/SKILL.md + README.md
set -euo pipefail

NAME="${1:-}"
DESC="${2:-TODO: описание триггеров и поведения}"

if [[ -z "$NAME" ]]; then
  echo "usage: $0 <skill-name> [\"description\"]"
  exit 1
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$REPO/skills/$NAME"

if [[ -e "$DIR" ]]; then
  echo "skill '$NAME' уже существует: $DIR"
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

TODO: опиши, что делает скил, когда триггерится и какой даёт результат.

## Когда срабатывает

- TODO

## Что делать

1. TODO
EOF

cat > "$DIR/README.md" <<EOF
# $NAME

$DESC

## Установка

Подхватывается автоматически после \`make install\` в корне репозитория.

## Использование

TODO: примеры запросов от пользователя.
EOF

echo "создан skills/$NAME/"
echo "  - SKILL.md"
echo "  - README.md"
