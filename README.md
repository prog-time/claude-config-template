# claude-config-template

> Russian: [README.ru.md](README.ru.md)

A template repository for your personal [Claude Code](https://docs.claude.com/en/docs/claude-code)
configuration. Fork it, fill it with your own skills and agents — the skeleton and tooling are
already in place.

The repository is intentionally **empty**: there are no ready-made skills or agents — only a
directory structure, Makefile, linter, install script, and minimal example stubs. All content
is added by you.

## Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| `claude` CLI | any | runtime environment |
| Python | 3.12+ | `scripts/lint_skills.py` and CI |
| `gh` CLI | any | optional, useful for GitHub-integrated skills |

## Structure

```text
skills/      user-defined skills (SKILL.md + resources)
agents/      sub-agents (individual .md files with frontmatter)
commands/    slash commands
mcp/         MCP server config examples
hooks/       PreToolUse / PostToolUse hooks, etc.
docs/        conventions, guides, changelog
scripts/     utilities: linter, new-skill generator
```

The repository is mounted into `~/.claude/` via symlinks. Any change in the repo is
picked up by Claude immediately — no manual file copying needed.

## First steps after forking

1. **Update LICENSE** — replace the author name and year in the `Copyright` line.
2. **Install** — run `make install` to create symlinks in `~/.claude/`.
3. **Add your skills** — use `make new-skill name=<slug> desc="..."`.
4. **Add your agents** — create a `.md` file in `agents/` following the `agents/example.md` stub.
5. **Check your installation** — `make doctor` diagnoses symlinks, tool versions, and configs.
6. **Validate files** — `make lint` checks frontmatter in all skills and agents.

## Quick start

```bash
# Fork the repository on GitHub, then:
git clone git@github.com:<you>/claude-config.git ~/code/claude-config
cd ~/code/claude-config
make install        # symlinks into ~/.claude
make lint           # validate SKILL.md and agents/*.md
```

To uninstall:

```bash
make uninstall      # removes only our symlinks, does not touch Anthropic built-ins
```

## Adding a new skill

```bash
make new-skill name=my-skill desc="Short description"
$EDITOR skills/my-skill/SKILL.md
make lint
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`docs/conventions.md`](docs/conventions.md) for
the full workflow and frontmatter specification.

## CI

GitHub Actions runs `scripts/lint_skills.py` on every push and PR — it verifies that every
`SKILL.md` has valid frontmatter and that the description does not exceed the length limit.

## License

[MIT](LICENSE)
