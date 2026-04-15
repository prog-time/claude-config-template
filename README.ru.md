# claude-config-template

> English: [README.md](README.md)

Шаблонный репозиторий для личной конфигурации [Claude Code](https://docs.claude.com/en/docs/claude-code).
Форкните его, наполните своими скилами и агентами — скелет и инструменты уже готовы.

Репозиторий намеренно **пустой**: здесь нет готовых скилов и агентов — только
структура каталогов, Makefile, линтер, скрипт установки и примеры-заглушки.
Всё содержимое добавляете вы.

## Требования

| Инструмент | Версия | Зачем |
|-----------|--------|-------|
| `claude` CLI | любая | основная среда исполнения |
| Python | 3.12+ | `scripts/lint_skills.py` и CI |
| `gh` CLI | любая | опционально, для скилов с интеграцией GitHub |

## Структура

```text
skills/      пользовательские скилы (SKILL.md + ресурсы)
agents/      сабагенты (отдельные .md с frontmatter)
commands/    slash-команды
mcp/         примеры конфигов MCP-серверов
hooks/       PreToolUse / PostToolUse и т. п.
docs/        соглашения, гайды, changelog
scripts/     утилиты: линтер, генератор нового скила
```

Репозиторий монтируется в `~/.claude/` через симлинки. Любое изменение в репо
мгновенно подхватывается Claude — не нужно копировать файлы вручную.

## Первые шаги после форка

1. **Обновите LICENSE** — замените имя автора и год в строке `Copyright`.
2. **Установите** — запустите `make install`, чтобы создать симлинки в `~/.claude/`.
3. **Добавьте свои скилы** — используйте `make new-skill name=<slug> desc="..."`.
4. **Добавьте своих агентов** — создайте `.md`-файл в `agents/` по образцу `agents/example.md`.
5. **Проверьте установку** — `make doctor` диагностирует симлинки, версии и конфиги.
6. **Проверьте файлы** — `make lint` валидирует frontmatter всех скилов и агентов.

## Быстрый старт

```bash
# Форкните репозиторий на GitHub, затем:
git clone git@github.com:<you>/claude-config.git ~/code/claude-config
cd ~/code/claude-config
make install        # симлинки в ~/.claude
make lint           # проверка SKILL.md и agents/*.md
```

Удаление:

```bash
make uninstall      # снимает только наши симлинки, встроенные скилы Anthropic не трогает
```

## Разработка нового скила

```bash
make new-skill name=my-skill desc="Короткое описание"
$EDITOR skills/my-skill/SKILL.md
make lint
```

Подробнее — в [`CONTRIBUTING.md`](CONTRIBUTING.md) и [`docs/conventions.md`](docs/conventions.md).

## CI

GitHub Actions запускает `scripts/lint_skills.py` на каждый push и PR — проверяет,
что у каждого `SKILL.md` валидный frontmatter и описание не превышает лимит.

## Лицензия

[MIT](LICENSE)
