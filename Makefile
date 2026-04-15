.PHONY: help install uninstall lint new-skill check

CLAUDE_HOME ?= $(HOME)/.claude
REPO := $(shell pwd)

help:
	@echo "claude-config — управление пользовательскими скилами и агентами"
	@echo ""
	@echo "  make install       создать симлинки в $(CLAUDE_HOME)"
	@echo "  make uninstall     удалить симлинки (встроенные скилы не трогает)"
	@echo "  make lint          валидация SKILL.md и agents/*.md"
	@echo "  make check         lint + dry-run install"
	@echo "  make new-skill name=<name> desc=\"<описание>\""

install:
	@./install.sh

uninstall:
	@./install.sh --uninstall

lint:
	@python3 scripts/lint_skills.py

check: lint
	@./install.sh --dry-run

new-skill:
	@if [ -z "$(name)" ]; then echo "usage: make new-skill name=<name> desc=\"<описание>\""; exit 1; fi
	@./scripts/new_skill.sh "$(name)" "$(desc)"
