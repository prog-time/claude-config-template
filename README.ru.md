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
| `ruff` | любая | линтер Python (`pip install ruff`) |
| `shfmt` | любая | форматтер bash-скриптов (`brew install shfmt` или `go install mvdan.cc/sh/v3/cmd/shfmt@latest`) |
| `codespell` | любая | проверка опечаток в документации (`pip install codespell`) |
| `jsonschema` | любая | валидация JSON-схемы (`pip install jsonschema`) — обязателен для pre-push |
| `gitleaks` | любая | сканер секретов (`brew install gitleaks`) — опционален для pre-push |

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

## Локальные проверки и pre-push

Директория `linting/` содержит хук pre-push, который запускает те же проверки, что и CI:
shellcheck, markdownlint, yamllint, ruff (линтер Python), shfmt (форматтер bash), codespell
(проверка опечаток), валидация JSON (обязательна) и сканер секретов gitleaks (опционален).

**JSON-валидация обязательна** — установите `jsonschema` перед первым пушем:

```bash
pip install jsonschema
```

**Сканирование секретов опционально** — если `gitleaks` не установлен, хук выводит
предупреждение и продолжает работу. Для локального сканирования секретов установите:

```bash
brew install gitleaks          # macOS
# Альтернатива через Docker: docker run zricethezav/gitleaks detect --source .
```

**Включить хук pre-push** — `make install` делает это автоматически, создавая симлинк
в `.git/hooks/`. Ручная установка:

```bash
cp linting/pre-push-check.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

Запустить проверки напрямую без установки хука:

```bash
bash linting/pre-push-check.sh
```

Также есть хук `prepare-commit-msg`, который дописывает список изменённых файлов
в сообщение коммита. Активация:

```bash
cp linting/prepare-commit-msg-check.sh .git/hooks/prepare-commit-msg
chmod +x .git/hooks/prepare-commit-msg
```

## CI

GitHub Actions запускает следующие проверки на каждый push и PR:

- `skills` — `scripts/lint_skills.py` проверяет frontmatter всех скилов и агентов
- `shellcheck` / `markdownlint` / `yamllint` / `ruff` / `shfmt` / `codespell` — стиль кода
- `gitleaks` — сканирует всю историю коммитов PR на предмет секретов; плейсхолдеры
  в примерах `mcp/` и документации внесены в allowlist `.gitleaks.toml`
- `json-validate` — проверяет синтаксис всех JSON-файлов; `.claude/settings*.json`
  валидируется по официальной схеме Claude Code settings
- `install-e2e` — реальный прогон установки в изолированный `CLAUDE_HOME=$(mktemp -d)`;
  проверяет создание симлинков для всех категорий, нулевой код выхода `scripts/doctor.sh`
  и полную очистку после `install.sh --uninstall`; в pre-push хук не входит
  (реальные симлинки и сеть в pre-push — вне scope)
- `link-check` — проверяет все ссылки в `README.md`, `README.ru.md`, `CONTRIBUTING.md`,
  `docs/**/*.md`, `skills/**/*.md`, `agents/**/*.md` через `markdown-link-check`;
  файлы из `tasks/**` исключены; паттерны игнорирования и политика retry — в
  `.markdown-link-check.json`; в pre-push хук не входит (сетевые вызовы в pre-push — вне scope)
- `branch-policy` — только для PR; проверяет, что имя ветки соответствует шаблону
  `^issues-[0-9]+$`; PR с лейблом `skip-branch-policy` пропускаются для внешних форков
- `lint-commands` — проверяет структурную анатомию каждого `commands/task_*.md` по
  правилам `_contract.md` §6 с помощью `scripts/lint_commands.py`; при пустом `commands/`
  завершается с кодом 0
- **Безопасность** — каждый job в workflow объявляет `permissions: contents: read`;
  каждый `uses:` запинен на 40-символьный SHA коммита с комментарием `# vX.Y.Z`;
  Dependabot (см. `.github/dependabot.yml`) еженедельно открывает PR-ы на обновление пинов

Полное определение workflow: [`.github/workflows/lint.yml`](.github/workflows/lint.yml).

## Лицензия

[MIT](LICENSE)
