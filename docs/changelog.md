# Changelog

All notable changes are recorded here. Format — [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versions — [SemVer](https://semver.org/).

## [Unreleased]

### Added

- Base repository structure: `skills/`, `agents/`, `commands/`, `mcp/`, `hooks/`, `docs/`, `scripts/`.
- Example skill: `hello-test`.
- Example agent: `agents/example.md` (stub).
- Linter `scripts/lint_skills.py` and generator `scripts/new_skill.sh`.
- `install.sh` — installation via symlinks into `~/.claude/`.
- GitHub Actions: lint + dry-run install.
