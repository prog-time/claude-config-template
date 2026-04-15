---
name: New skill proposal
about: Propose adding a new example skill to the template
labels: new-skill
---

## Skill name (slug)

The kebab-case directory name, e.g. `code-reviewer`.

## What it does

A one-paragraph description of what this skill instructs Claude to do when triggered.

## Trigger conditions

When should Claude invoke this skill? List typical user phrases or task patterns.

## Contribution checklist

Before submitting a PR for this skill:

- [ ] `skills/<name>/SKILL.md` created with valid frontmatter (`name`, `description`)
- [ ] `skills/<name>/README.md` created explaining the skill for humans
- [ ] `make lint` passes locally with no errors
- [ ] No hardcoded paths, tokens, email addresses, or real URLs in the skill files
- [ ] Skill content is generic — no personal workflow assumptions

## Additional notes

Any context, dependencies, or open questions.
