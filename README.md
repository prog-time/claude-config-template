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
| `ruff` | any | Python linter (`pip install ruff`) |
| `shfmt` | any | shell formatter (`brew install shfmt` or `go install mvdan.cc/sh/v3/cmd/shfmt@latest`) |
| `codespell` | any | spell checker for docs (`pip install codespell`) |
| `jsonschema` | any | JSON schema validator (`pip install jsonschema`) — required for pre-push |
| `gitleaks` | any | secret scanner (`brew install gitleaks`) — optional for pre-push |

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

## Local checks and pre-push

The `linting/` directory provides a pre-push hook that runs the same checks as CI locally:
shellcheck, markdownlint, yamllint, ruff (Python), shfmt (shell formatter), codespell (spell
check), JSON validation (mandatory), and gitleaks secret scanning (optional).

**JSON validation is mandatory** — install `jsonschema` before your first push:

```bash
pip install jsonschema
```

**Secret scanning is optional** — if `gitleaks` is not installed, the pre-push hook prints a
warning and continues. Install it to enable local secret scanning:

```bash
brew install gitleaks          # macOS
# Docker alternative: docker run zricethezav/gitleaks detect --source .
```

**Enable the pre-push hook** — `make install` does this automatically by creating a symlink
in `.git/hooks/`. To set it up manually:

```bash
cp linting/pre-push-check.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

Run the checks directly without installing the hook:

```bash
bash linting/pre-push-check.sh
```

There is also a `prepare-commit-msg` hook that appends a file-change summary to your commit
message. To activate it:

```bash
cp linting/prepare-commit-msg-check.sh .git/hooks/prepare-commit-msg
chmod +x .git/hooks/prepare-commit-msg
```

## CI

GitHub Actions runs the following checks on every push and PR:

- `skills` — `scripts/lint_skills.py` validates frontmatter in all skills and agents
- `shellcheck` / `markdownlint` / `yamllint` / `ruff` / `shfmt` / `codespell` — code style
- `gitleaks` — scans the full PR commit history for secrets; placeholder values in `mcp/`
  examples and docs are allowlisted in `.gitleaks.toml`
- `json-validate` — syntax-checks all JSON files; validates `.claude/settings*.json` against
  the official Claude Code settings schema
- `install-e2e` — real end-to-end install run into an isolated `CLAUDE_HOME=$(mktemp -d)`;
  asserts all category symlinks are created, `scripts/doctor.sh` exits 0, and
  `install.sh --uninstall` removes every symlink cleanly; not run in the pre-push hook
  (network-free, real-symlink setup is out of scope locally)
- `link-check` — checks all links in `README.md`, `README.ru.md`, `CONTRIBUTING.md`,
  `docs/**/*.md`, `skills/**/*.md`, `agents/**/*.md` using `markdown-link-check`;
  `tasks/**` is excluded; ignore patterns and retry policy are in `.markdown-link-check.json`;
  not run in the pre-push hook (network calls in pre-push are out of scope)
- **Security posture** — every workflow job declares `permissions: contents: read`;
  every `uses:` is pinned to a 40-char commit SHA with a `# vX.Y.Z` comment; Dependabot
  (see `.github/dependabot.yml`) opens weekly PRs to bump pins

See [`.github/workflows/lint.yml`](.github/workflows/lint.yml) for the full workflow definition.

## License

[MIT](LICENSE)
