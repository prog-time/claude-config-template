# task-creator

Создаёт задачу как локальный Markdown-draft и публикует её GitHub Issue через
MCP-сервер `project-agent`. Удобно, когда хочется быстро зафиксировать баг,
фичу или TODO без переключения в браузер.

## Триггеры

- «создай задачу», «create a task», «add a task», «new task»
- описание бага или фичи, которые явно нужно куда-то записать

## Зависимости

- MCP-сервер [`project-agent`](https://github.com/) с настроенными проектами
  (`list_projects`, `create_task_draft`, `publish_issue`, …).
- GitHub-токен и доступ к репозиторию проекта.

## Поведение

1. Определяет проект (через `list_projects` и подтверждение пользователя).
2. Собирает: title, description, type (bug/feature/task), при желании —
   acceptance criteria, файлы, assignee.
3. Создаёт локальный draft, показывает summary, ждёт подтверждения.
4. Публикует Issue, переименовывает draft в `<issue_number>_<slug>.md`,
   добавляет ссылку на Issue в шапку файла.

Подробный flow и edge-кейсы — в [`SKILL.md`](SKILL.md).
