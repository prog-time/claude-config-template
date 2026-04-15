---
name: task-creator
description: >
  Automates task creation by generating a local Markdown draft and publishing it as a GitHub Issue
  via the project-agent MCP. Use this skill whenever the user says "создай задачу", "create a task",
  "add a task", "new task", or anything that implies they want to file a new task or issue in their
  project. Also trigger when the user describes a bug, feature request, or piece of work and seems
  to want it tracked — even if they don't explicitly say "task" or "issue".
---

# Task Creator

You help users create well-structured tasks that get saved both as local Markdown files and as
GitHub Issues. The goal is to make task creation fast and painless while ensuring every task has
enough context for someone to pick it up and start working.

## Available Tools

This skill relies on the **project-agent** MCP server, which provides these tools:

- `list_projects` — discover available projects and their repos
- `create_task_draft` — create a local `.md` draft file
- `publish_issue` — publish a draft as a GitHub Issue
- `list_drafts` — see unpublished drafts for a project
- `fetch_issue` — look up an existing issue
- `add_comment` — comment on an existing issue
- `update_issue` — change state, title, labels, or assignee

## Workflow

### Step 1 — Gather Task Details

Start by figuring out which project this task belongs to. Call `list_projects` to see what's
available, then ask the user to pick one (or confirm if there's an obvious match from context).

Then collect the task information interactively. You need at minimum:

- **Title** — a concise summary of what needs to be done
- **Description** — enough detail that someone unfamiliar could understand the task
- **Type** — bug, feature, or task (default to "task" if unclear)

Optionally also gather:

- **Acceptance criteria** — concrete checklist items that define "done"
- **Affected files** — specific file paths relevant to the task
- **Assignee** — GitHub username to assign
- **Additional notes** — context, links, related issues

If the user provides everything in one message (e.g., "создай задачу: добавить авторизацию через
OAuth, нужно поддержать Google и GitHub провайдеры"), extract what you can and ask only about
what's missing. Don't ask questions you already have answers to.

### Step 2 — Create the Draft

Use `create_task_draft` to generate the local Markdown file:

```
create_task_draft(
  project: "<selected project>",
  title: "<task title>",
  context: "<full description with acceptance criteria and notes>",
  type: "task" | "bug" | "feature",
  checklist: ["criterion 1", "criterion 2", ...],
  files: ["path/to/relevant/file", ...],
  assignee: "<github username>"  // if provided
)
```

The `context` field should be formatted as a clear task description. Structure it like this:

```
## Description
<Detailed description of the task>

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Notes
<Additional context, related issues, links>
```

After creating the draft, show the user a summary of what was created and ask for confirmation
before publishing.

### Step 3 — Publish as GitHub Issue

Once the user confirms, use `publish_issue` to create the GitHub Issue:

```
publish_issue(
  project: "<selected project>",
  draftFile: "<path returned by create_task_draft>",
  type: "task" | "bug" | "feature",
  assignee: "<github username>"  // if provided
)
```

After publishing, report back to the user with:
- The issue number
- A direct link to the issue on GitHub
- Confirmation that both the local file and the GitHub Issue are in sync

### Step 4 — Rename the Local File

After getting the issue number from the publish step, rename the local draft file to include the
issue number. The naming convention is:

```
tasks/<project>/draft_<task_name>.md  →  tasks/<project>/<issue_number>_<task_name>.md
```

Use a bash command to rename:
```bash
mv "<original_path>" "<new_path_with_issue_number>"
```

Then update the file to add a GitHub Issue reference at the top:

```markdown
> GitHub Issue: #<issue_number> — https://github.com/<owner>/<repo>/issues/<issue_number>
```

## Language Handling

The user may write in Russian, English, or a mix. Match the language of your responses to whatever
the user is writing in. Task content (title, description) should be in whatever language the user
provides it in — don't translate unless asked.

## Edge Cases

- **User provides a vague description**: Ask clarifying questions. A good task title and a sentence
  or two of description is the minimum bar.
- **No projects available**: Let the user know that no projects are configured in project-agent and
  suggest they set one up.
- **Publish fails**: Keep the draft file intact and tell the user what went wrong. The draft can
  be published later using `publish_issue`.
- **User wants to batch-create tasks**: Handle them one at a time, confirming each before moving
  to the next.

## Example Interaction

**User:** создай задачу — нужно добавить поддержку тёмной темы в мобильное приложение

**Assistant:** *(calls list_projects, shows options, user picks "talksy")*

Got it! Here's what I'll create:

**Title:** Добавить поддержку тёмной темы в мобильное приложение
**Type:** feature
**Project:** talksy

Before I file this, do you want to add any acceptance criteria or notes? For instance, which
screens should support dark mode, or any design references?

**User:** да, критерии: все экраны поддерживают тёмную тему, переключатель в настройках, сохранение
выбора между сессиями

**Assistant:** *(creates draft, shows summary, publishes after confirmation)*

Done! Created issue #42 in talksy:
https://github.com/prog-time/talksy/issues/42

The local file has been saved as `tasks/talksy/42_dark-theme-support.md`.
