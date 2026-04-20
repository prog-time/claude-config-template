# Contributing

This guide is for anyone who wants to add a skill, an agent, or fix something
in the repository template itself. If you maintain a personal fork, do whatever
works for you; the rules below apply to contributions to the shared template.

## Adding a skill

### 1. Create the structure

```bash
make new-skill name=my-skill desc="Short description of what the skill does"
```

The generator will create `skills/my-skill/SKILL.md` and `skills/my-skill/README.md`
with the required boilerplate.

### 2. Fill in SKILL.md

Minimal frontmatter:

```yaml
---
name: my-skill
description: >
  What the skill does and WHEN to trigger it. Write it as a set of trigger
  signals.
---
```

The full frontmatter specification is in [`docs/conventions.md`](docs/conventions.md).

### 3. Fill in README.md

The goal is to explain the skill to a human in 30 seconds: what it does, how
to invoke it, what its dependencies are. Do not copy text from SKILL.md.

### 4. Validate

```bash
make lint
```

The linter checks frontmatter and scans files for accidentally hardcoded
values (paths, tokens, emails). No errors means it is ready to commit.

---

## Adding an agent

There is no generator for agents. Create the file manually:

```bash
cp agents/example.md agents/my-agent.md
```

Edit `agents/my-agent.md`. Required frontmatter fields:

```yaml
---
name: my-agent
description: >
  What the agent does. Used by Claude when selecting a sub-agent.
tools: Bash, Read, Grep
model: sonnet
---
```

The full specification is in [`docs/conventions.md`](docs/conventions.md).
Use [`agents/example.md`](agents/example.md) as a reference.

---

## Local workflow (full cycle)

```bash
# Create a skill
make new-skill name=my-skill desc="Description"

# Edit
$EDITOR skills/my-skill/SKILL.md
$EDITOR skills/my-skill/README.md

# Validate frontmatter
make lint

# Commit
git add skills/my-skill
git commit -m "feat(skills): add my-skill"
```

---

## Frontmatter requirements (summary)

| Field | Skill (`SKILL.md`) | Agent (`agents/*.md`) |
|-------|--------------------|-----------------------|
| `name` | required, matches directory name | required, matches file name |
| `description` | required, ≤ 1024 characters | required |
| `model` | optional | optional |
| `allowed-tools` / `tools` | optional | optional (recommended) |

Full specification: [`docs/conventions.md`](docs/conventions.md).

---

## Local checks and pre-push

The `linting/` directory contains a `pre-push-check.sh` orchestrator that runs shellcheck,
markdownlint, yamllint, ruff, shfmt, codespell, JSON validation, and gitleaks secret scanning
— the same set as CI. Enable it so errors are caught before pushing.

Install the required linters before your first push:

```bash
pip install ruff codespell jsonschema   # Python linter + spell checker + JSON schema validator
brew install shfmt                      # shell formatter (macOS)
# Linux / no brew: go install mvdan.cc/sh/v3/cmd/shfmt@latest
```

Install `gitleaks` for optional local secret scanning:

```bash
brew install gitleaks          # macOS
# Docker alternative: docker run zricethezav/gitleaks detect --source .
```

**JSON validation is mandatory** — the pre-push hook fails if `jsonschema` is not installed.
**Secret scanning is optional** — if `gitleaks` is not installed, the hook prints a warning
and continues. CI always runs gitleaks regardless of local setup.

**Automatic setup** — running `make install` creates a symlink in `.git/hooks/pre-push`
automatically. If you prefer manual setup:

```bash
cp linting/pre-push-check.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

Run checks directly at any time:

```bash
bash linting/pre-push-check.sh
```

There is also an optional `prepare-commit-msg` hook that appends a list of staged files
to the commit message:

```bash
cp linting/prepare-commit-msg-check.sh .git/hooks/prepare-commit-msg
chmod +x .git/hooks/prepare-commit-msg
```

---

## CI

GitHub Actions runs the following checks on every push and PR:
`skills`, `shellcheck`, `markdownlint`, `yamllint`, `ruff`, `shfmt`, `codespell`,
`gitleaks` (secret scan), `json-validate` (syntax + schema), `install-e2e`
(real install run), `link-check` (Markdown link validation),
`branch-policy` (PR branch name validation), and `lint-commands`
(`commands/task_*.md` structural check per `_contract.md` §6).

Three content-integrity and policy jobs run in CI only — they are not part of the pre-push hook:

- **`install-e2e`** — runs `install.sh` for real into an isolated `CLAUDE_HOME=$(mktemp -d)`,
  asserts every symlink in `skills/`, `agents/`, `commands/`, `hooks/` is created,
  runs `scripts/doctor.sh`, then runs `install.sh --uninstall` and asserts all symlinks
  are gone. New skills and agents are picked up automatically — no changes to the job
  needed. Not in pre-push: real symlinks and network access are out of scope locally.
- **`link-check`** — runs `markdown-link-check` over all published `.md` files
  (`README.md`, `README.ru.md`, `CONTRIBUTING.md`, `docs/**/*.md`, `skills/**/*.md`,
  `agents/**/*.md`). `tasks/**` is excluded. Ignore patterns for placeholders and
  localhost URLs, plus a retry policy for 429/503, are configured in
  `.markdown-link-check.json`. Not in pre-push: network calls in pre-push are out of scope.
  When adding `.md` files with placeholder links (e.g. `<YOUR_REPO_URL>`), add a matching
  pattern to `.markdown-link-check.json` so the CI job does not treat them as broken links.
- **`branch-policy`** — PR-only job that validates `github.head_ref` against the pattern
  `^issues-[0-9]+$`. Fails fast with a descriptive message if the branch name does not match.
  PRs from external forks can be allowed through by adding the `skip-branch-policy` label
  (maintainer creates this label once in repository settings). Not triggered on `push` to
  `main` (no `head_ref` on direct pushes).
- **`lint-commands`** — runs `scripts/lint_commands.py` to validate the structural anatomy
  of every `commands/task_*.md` file per `_contract.md` §6: checks for the `# /task_*`
  H1 heading, a `_contract.md` reference in the first body paragraph, and required blocks
  (`**Preconditions:**`, `**Action:**`, `**Failure modes:**`, `**Invariants after:**`) in
  every `### Step` section. Exits 0 if no command files are present (safe for forks that
  have not yet added any commands). Not in pre-push: the template ships with an empty
  `commands/` directory, so local linting adds no value until commands are installed.

Reproduce locally:

```bash
make lint           # standard check
make check          # lint + dry-run install
bash linting/pre-push-check.sh   # full pre-push suite including JSON + gitleaks
```

When adding a new GitHub Action, pin it to a 40-char commit SHA with a `# vX.Y.Z`
comment (e.g. `uses: owner/action@<sha> # v1.2.3`). Dependabot will keep the pin
fresh via weekly PRs. Declare per-job `permissions: contents: read` so forks inherit
a safe default `GITHUB_TOKEN` scope.

---

## Branch naming policy

All contribution branches must follow the pattern `issues-{N}` where `{N}` is the linked
GitHub Issue number (e.g. `issues-42`). The CI job `branch-policy` enforces this on every PR:

- A PR from `feature/foo` or `fix/bar` will fail the `branch-policy` check.
- If you are contributing from a fork and cannot rename the branch (e.g. you opened the PR
  before reading this), ask a maintainer to add the `skip-branch-policy` label to your PR.
  The maintainer creates this label once in the repository settings; it is not in the repo code.

Quick start for contributors:

```bash
git checkout -b issues-42    # N = the GitHub Issue number for your task
git push -u origin issues-42
# open PR — branch-policy will pass
```

---

## What should NOT go into the template

- Specific production skills and agents — only example stubs.
- Personal paths, tokens, emails, URLs of specific repositories.
- Links to removed skills (`commit`, `task-creator`, `team-lead-router`).
