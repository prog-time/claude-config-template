# Conventions

## Skill structure

```text
skills/<name>/
├── SKILL.md      required, for the model
├── README.md     required, for humans
├── scripts/      optional: helper scripts
├── references/   optional: extra .md files referenced from SKILL.md
└── assets/       optional: templates, images, fixtures
```

## `SKILL.md` frontmatter

```yaml
---
name: <kebab-case, matches the directory name>
description: >
  What the skill does and WHEN to trigger it. Write it as a set of signals,
  not a general description. Include typical user phrasings in every language
  you support.
model: sonnet         # optional
allowed-tools:        # optional, if you want to restrict
  - Read
  - Grep
---
```

Rules:

- `description` is the primary trigger. If the skill does not activate, the
  problem is almost always here.
- `description` limit is 1024 characters. The linter will catch overruns.
- The name in frontmatter matches the directory name (for agents — the
  file name).

## Agent frontmatter

```yaml
---
name: <kebab-case, matches the file name without .md>
description: >
  What the agent does. Used by Claude itself when selecting a sub-agent.
tools: Bash, Read, Edit, Write   # explicit list of allowed tools
model: sonnet                     # opus for orchestrators, sonnet is the usual default
---
```

## `SKILL.md` content

- Write instructions in the imperative: "Do", "Do not".
- Clear "What to do" and "What NOT to do" — short lists beat long paragraphs.
- If there are steps, number them.
- Provide examples with realistic user phrasings.

## `README.md` content (for GitHub)

The goal is for anyone opening the repo to understand what the skill does in
30 seconds. Minimum: triggers, dependencies, usage example. Do not copy
content from SKILL.md.

## Commits

[Conventional Commits](https://www.conventionalcommits.org):

```text
feat(skills): add code-reviewer skill
fix(agents): correct tool list for commit agent
docs: update README install section
chore(ci): bump setup-python to v5
```

Scopes: `skills`, `agents`, `commands`, `mcp`, `hooks`, `scripts`, `docs`, `ci`.

## Linter (`scripts/lint_skills.py`)

Runs via `make lint`. Checks:

- presence and correctness of frontmatter (`name`, `description`) in all
  `SKILL.md` and `agents/*.md`;
- length of `description` (1024-character limit);
- that `name` in frontmatter matches the directory/file name.

Additionally scans files in `skills/`, `agents/`, `commands/`, `hooks/` for
**hardcoded values** (warnings, not errors):

| What we look for | Example |
|------------------|---------|
| Absolute paths | `/Users/you/projects` |
| Email addresses | `you@example.com` |
| GitHub PAT | `ghp_...` |
| OpenAI key | `sk-...` |
| Bearer token | `Bearer abc123` |

Strict mode — warnings become errors:

```bash
python3 scripts/lint_skills.py --strict
```

## Languages

- README, docs, CHANGELOG — English by default. A Russian translation of the
  README is kept at `README.ru.md`; forks may add other translations as
  additional `README.<lang>.md` files.
- Frontmatter, file and directory names, comments in scripts — English.
- `SKILL.md` content — in the language(s) the user most often uses to invoke
  the skill. Include trigger phrases in every supported language.
