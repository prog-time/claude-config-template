# Changelog

Все заметные изменения фиксируем здесь. Формат — [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/),
версии — [SemVer](https://semver.org/lang/ru/).

## [Unreleased]

### Added
- Базовая структура репозитория: `skills/`, `agents/`, `commands/`, `mcp/`, `hooks/`, `docs/`, `scripts/`.
- Скилы: `commit`, `task-creator`, `team-lead-router`.
- Агенты: `commit`, `team-lead` (шаблоны).
- Линтер `scripts/lint_skills.py` и генератор `scripts/new_skill.sh`.
- `install.sh` — установка через симлинки в `~/.claude/`.
- GitHub Actions: lint + dry-run install.
