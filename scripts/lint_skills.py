#!/usr/bin/env python3
"""Validate SKILL.md and agent .md frontmatter across the repo.

Checks:
- file starts with a YAML frontmatter delimited by ---
- has required keys (`name`, `description`)
- `description` length is within Claude's limit (1024 chars)
- `name` matches the directory name (for skills) or file stem (for agents)
"""

from __future__ import annotations

import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
MAX_DESCRIPTION = 1024

errors: list[str] = []
warnings: list[str] = []


def parse_frontmatter(text: str) -> dict[str, str] | None:
    """Very small YAML-ish frontmatter parser. Supports scalars and folded `>` blocks."""
    if not text.startswith("---"):
        return None
    lines = text.splitlines()
    if len(lines) < 2:
        return None
    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break
    if end is None:
        return None

    data: dict[str, str] = {}
    current_key: str | None = None
    folded = False
    buf: list[str] = []

    def flush() -> None:
        nonlocal current_key, buf, folded
        if current_key is not None:
            value = " ".join(s.strip() for s in buf).strip() if folded else "\n".join(buf).strip()
            data[current_key] = value.strip().strip('"').strip("'")
        current_key, buf, folded = None, [], False

    for raw in lines[1:end]:
        if not raw.strip():
            if current_key is not None and folded:
                buf.append("")
            continue
        if raw[0] != " " and ":" in raw:
            flush()
            key, _, value = raw.partition(":")
            key = key.strip()
            value = value.strip()
            if value in (">", "|", ">-", "|-"):
                current_key = key
                folded = value.startswith(">")
                buf = []
            else:
                data[key] = value.strip().strip('"').strip("'")
        else:
            buf.append(raw.strip())
    flush()
    return data


def check_skill(path: Path) -> None:
    rel = path.relative_to(REPO)
    text = path.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    if fm is None:
        errors.append(f"{rel}: missing or malformed frontmatter")
        return
    for key in ("name", "description"):
        if key not in fm or not fm[key]:
            errors.append(f"{rel}: missing required key '{key}'")
    if "description" in fm and len(fm["description"]) > MAX_DESCRIPTION:
        errors.append(
            f"{rel}: description is {len(fm['description'])} chars (max {MAX_DESCRIPTION})"
        )
    expected = path.parent.name
    if fm.get("name") and fm["name"] != expected:
        warnings.append(
            f"{rel}: frontmatter name '{fm['name']}' != directory '{expected}'"
        )


def check_agent(path: Path) -> None:
    rel = path.relative_to(REPO)
    text = path.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    if fm is None:
        errors.append(f"{rel}: missing or malformed frontmatter")
        return
    for key in ("name", "description"):
        if key not in fm or not fm[key]:
            errors.append(f"{rel}: missing required key '{key}'")
    expected = path.stem
    if fm.get("name") and fm["name"] != expected:
        warnings.append(
            f"{rel}: frontmatter name '{fm['name']}' != filename '{expected}'"
        )


def main() -> int:
    skills_dir = REPO / "skills"
    agents_dir = REPO / "agents"

    skill_files = sorted(skills_dir.glob("*/SKILL.md"))
    agent_files = sorted(agents_dir.glob("*.md"))

    print(f"Linting {len(skill_files)} skill(s) and {len(agent_files)} agent(s)…")
    for p in skill_files:
        check_skill(p)
    for p in agent_files:
        check_agent(p)

    for w in warnings:
        print(f"warn: {w}")
    for e in errors:
        print(f"FAIL: {e}")

    if errors:
        print(f"\n{len(errors)} error(s), {len(warnings)} warning(s).")
        return 1
    print(f"OK ({len(warnings)} warning(s)).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
