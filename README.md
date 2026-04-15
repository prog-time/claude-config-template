# claude-config

Личный конфиг для [Claude Code](https://docs.claude.com/en/docs/claude-code) и
[Cowork](https://www.anthropic.com/) — скилы, агенты, slash-команды, MCP-конфиги
и хуки в одном версионируемом репозитории.

Этот репозиторий монтируется в `~/.claude/` через симлинки. Любое изменение в
репо мгновенно подхватывается Claude — не нужно копировать файлы вручную.

## Содержание

```
skills/      пользовательские скилы (SKILL.md + ресурсы)
agents/      сабагенты (отдельные .md с frontmatter)
commands/    slash-команды
mcp/         примеры конфигов MCP-серверов
hooks/       PreToolUse / PostToolUse и т. п.
docs/        соглашения, гайды, changelog
scripts/     утилиты: линтер, генератор нового скила
```

## Быстрый старт

```bash
git clone git@github.com:<you>/claude-config.git ~/code/claude-config
cd ~/code/claude-config
make install        # симлинки в ~/.claude
make lint           # проверка SKILL.md
```

Удаление:

```bash
make uninstall      # снимает только наши симлинки, встроенные скилы Anthropic не трогает
```

## Что внутри

### Скилы

| Скил | Что делает |
|---|---|
| [`commit`](skills/commit) | Делегирует git-коммиты агенту `commit`. Поддерживает `commit ru`, `commit file1 file2`. |
| [`task-creator`](skills/task-creator) | Создаёт задачу как локальный draft + GitHub Issue через MCP `project-agent`. |
| [`team-lead-router`](skills/team-lead-router) | Маршрутизирует все задачи, связанные с кодом, к агенту `team-lead`. |

### Агенты

| Агент | Назначение |
|---|---|
| [`commit`](agents/commit.md) | Анализирует diff, бьёт изменения на атомарные коммиты, генерирует сообщения. |
| [`team-lead`](agents/team-lead.md) | Оркестратор: разбирает задачу, поднимает специализированных агентов, собирает результат. |

## Соглашения

Подробности в [`docs/conventions.md`](docs/conventions.md). Кратко:

- один скил — одна папка `skills/<name>/` с `SKILL.md` (для модели) и `README.md` (для людей);
- frontmatter `SKILL.md` — `name`, `description`, опционально `model`, `allowed-tools`;
- `description` — основной триггер для активации, держим под 1024 символа;
- агенты — отдельные `.md` в `agents/`, переиспользуются между скилами;
- коммиты — [Conventional Commits](https://www.conventionalcommits.org/);
- комментарии в коде и frontmatter — на английском, README и docs — на русском.

## Разработка нового скила

```bash
./scripts/new_skill.sh my-skill "Короткое описание"
$EDITOR skills/my-skill/SKILL.md
make lint
git add skills/my-skill && git commit -m "feat(skills): add my-skill"
```

## CI

GitHub Actions запускает `scripts/lint_skills.py` на каждый push и PR — проверяет,
что у каждого `SKILL.md` валидный frontmatter и описание не превышает лимит.

## Лицензия

[MIT](LICENSE)
