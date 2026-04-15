---
name: commit
description: >
  Delegates git staging and committing to the dedicated `commit` agent.
  Use this skill whenever the user asks to commit changes, stage files,
  create a git commit, or says "commit" in any form. Also trigger when
  the user describes finished work and wants to save it to git — even
  without the word "commit" (e.g., "save my changes", "I'm done, push
  this", "закоммить", "коммит").
  Supports compact syntax: `commit` (all changes), `commit ru` (Russian
  messages), `commit file1 file2` (specific files).
---

This skill exists for one reason: to hand off commit work to the `commit` agent, which lives at `~/.claude/agents/commit.md`.

## What to do

When this skill triggers, delegate the task to the **commit** agent immediately. Do not analyze changes, write commit messages, or run git commands yourself — the agent handles all of that.

### How to delegate

Use the Agent tool (subagent) with `subagent_type: "commit"` or, if unavailable, invoke the agent by reading its instructions from `~/.claude/agents/commit.md` and following them.

### Passing arguments

The user's message may contain arguments. Pass them through as-is:

- **No arguments** (`commit`) — the agent will analyze all changes and create atomic commits.
- **Language code** (`commit ru`, `commit de`) — the agent will write messages in that language.
- **File paths** (`commit src/auth.ts tests/auth.test.ts`) — the agent will commit only those files.

### What NOT to do

- Do not generate commit messages yourself.
- Do not run `git add` or `git commit` yourself.
- Do not ask the user to confirm the commit message — the agent handles the full workflow without confirmation prompts.
- Do not add `Co-Authored-By` or any AI attribution to commits.
