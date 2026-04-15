.PHONY: help install uninstall lint lint-md lint-yaml new-skill check doctor

CLAUDE_HOME ?= $(HOME)/.claude
REPO := $(shell pwd)

help:
	@echo "claude-config — manage user-defined skills and agents"
	@echo ""
	@echo "  make install       create symlinks in $(CLAUDE_HOME)"
	@echo "  make uninstall     remove symlinks (leaves built-in skills alone)"
	@echo "  make lint          validate SKILL.md and agents/*.md"
	@echo "  make lint-md       run markdownlint on *.md"
	@echo "  make lint-yaml     run yamllint on *.yml/*.yaml"
	@echo "  make check         lint + lint-md + lint-yaml + dry-run install"
	@echo "  make doctor        diagnose installation (symlinks, versions, configs)"
	@echo "  make new-skill name=<name> desc=\"<description>\""

install:
	@./install.sh

uninstall:
	@./install.sh --uninstall

lint:
	@python3 scripts/lint_skills.py

lint-md:
	@command -v markdownlint >/dev/null 2>&1 || { echo "markdownlint not installed: npm install -g markdownlint-cli"; exit 1; }
	@markdownlint --ignore-path .markdownlintignore "**/*.md"

lint-yaml:
	@command -v yamllint >/dev/null 2>&1 || { echo "yamllint not installed: pip install yamllint"; exit 1; }
	@yamllint .

check: lint lint-md lint-yaml
	@./install.sh --dry-run

doctor:
	@./scripts/doctor.sh

new-skill:
	@if [ -z "$(name)" ]; then echo "usage: make new-skill name=<name> desc=\"<description>\""; exit 1; fi
	@./scripts/new_skill.sh "$(name)" "$(desc)"
