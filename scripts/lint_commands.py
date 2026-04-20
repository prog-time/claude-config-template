#!/usr/bin/env python3
"""Validate structural anatomy of commands/task_*.md files.

Checks per _contract.md §6 and §9:
  1. File has an H1 heading matching `# /task_<name>`.
  2. First body paragraph (after H1 and optional frontmatter block) contains
     a reference to `_contract.md`.
  3. Every ### Step section contains **Preconditions:**, **Action:**,
     **Failure modes:**, and **Invariants after:** blocks.

Scope (MVP):
  - Only lints `commands/task_*.md` files.
  - Skips `commands/_contract.md`, `commands/README.md`, any non-`task_`-prefixed
    file, and all `commands/_shared/*.md` files (deferred to a follow-up task).

Output format: `path/file.md:LINE: message`  (GitHub Actions annotation-compatible)
Exit codes:
  0 — all files OK (or no files found)
  1 — one or more structural violations found
  2 — internal error (unexpected IO / parse crash)

Usage:
  python3 scripts/lint_commands.py [commands_dir]
  Default commands_dir: <repo_root>/commands
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

REPO = Path(__file__).resolve().parent.parent

# Step section heading: ### Step N, Step 1a, Step 2.5, Step 2a, etc.
STEP_HEADING_RE = re.compile(r"^### Step\s+", re.MULTILINE)

# Required bold-marker blocks inside each Step section
REQUIRED_BLOCKS: list[tuple[str, re.Pattern[str]]] = [
    ("**Preconditions:**", re.compile(r"^\*\*Preconditions:\*\*", re.MULTILINE)),
    ("**Action:**", re.compile(r"^\*\*Action:\*\*", re.MULTILINE)),
    ("**Failure modes:**", re.compile(r"^\*\*Failure modes:\*\*", re.MULTILINE)),
    ("**Invariants after:**", re.compile(r"^\*\*Invariants after:\*\*", re.MULTILINE)),
]

# H1 for task commands must be `# /task_<something>`
H1_TASK_RE = re.compile(r"^# /task_\S+", re.MULTILINE)

MAX_VIOLATIONS_PER_FILE = 5


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _section_boundaries(lines: list[str]) -> list[tuple[int, int, str]]:
    """Return list of (start_line_1based, end_line_1based_exclusive, heading_text)
    for every ### Step section in the file."""
    boundaries: list[tuple[int, int, str]] = []
    step_indices: list[tuple[int, str]] = []

    for i, line in enumerate(lines):
        if re.match(r"^### Step\s+", line):
            step_indices.append((i, line.rstrip()))

    for idx, (lineno, heading) in enumerate(step_indices):
        if idx + 1 < len(step_indices):
            end = step_indices[idx + 1][0]
        else:
            end = len(lines)
        # Find the next ## or # heading to cap the section
        next_major = end
        for j in range(lineno + 1, end):
            if re.match(r"^#{1,2} ", lines[j]):
                next_major = j
                break
        boundaries.append((lineno + 1, min(end, next_major), heading))

    return boundaries


def _first_body_paragraph(lines: list[str]) -> str:
    """Extract the first non-empty paragraph after the H1 heading,
    skipping frontmatter (---…---) if present."""
    # Skip frontmatter block at the start if present
    start = 0
    if lines and lines[0].startswith("---"):
        for i in range(1, len(lines)):
            if lines[i].strip() == "---":
                start = i + 1
                break

    # Find the H1 heading
    h1_line = -1
    for i in range(start, len(lines)):
        if lines[i].startswith("# "):
            h1_line = i
            break

    if h1_line == -1:
        return ""

    # Collect first non-empty paragraph after H1
    in_paragraph = False
    paragraph_lines: list[str] = []
    for i in range(h1_line + 1, len(lines)):
        line = lines[i]
        if not line.strip():
            if in_paragraph:
                break
        else:
            in_paragraph = True
            paragraph_lines.append(line)

    return "\n".join(paragraph_lines)


# ---------------------------------------------------------------------------
# Per-file linter
# ---------------------------------------------------------------------------


def lint_file(path: Path, base: Path | None = None) -> list[str]:
    """Lint one task_*.md file. Returns list of 'path:line: message' strings.

    base: root used to compute relative path in messages.  Defaults to REPO.
    When linting files outside the repo tree (pre-flight testing), pass the
    parent of the commands dir.
    """
    violations: list[str] = []
    if base is None:
        base = REPO
    try:
        rel = str(path.relative_to(base))
    except ValueError:
        rel = str(path)

    try:
        text = path.read_text(encoding="utf-8")
        lines = text.splitlines()
    except OSError as exc:
        return [f"{rel}:1: IO error reading file: {exc}"]

    def add(lineno: int, msg: str) -> None:
        """Append a violation."""
        violations.append(f"{rel}:{lineno}: {msg}")

    # Rule 1 — H1 heading must be `# /task_<name>`
    h1_match = H1_TASK_RE.search(text)
    if not h1_match:
        add(1, "missing top-level # /task_* heading")
        h1_lineno = 0
    else:
        h1_lineno = text[: h1_match.start()].count("\n") + 1

    # Rule 2 — first body paragraph must reference `_contract.md`
    first_para = _first_body_paragraph(lines)
    if "_contract.md" not in first_para:
        add(h1_lineno + 1, "first body paragraph does not reference _contract.md")

    # Rule 3 — every ### Step section must have required blocks
    sections = _section_boundaries(lines)
    for sec_start, sec_end, heading in sections:
        sec_lines = lines[sec_start:sec_end]
        sec_text = "\n".join(sec_lines)
        for block_name, block_re in REQUIRED_BLOCKS:
            if not block_re.search(sec_text):
                msg = f"step '{heading.strip()}' missing {block_name}"
                add(sec_start, msg)

    return _maybe_truncate(violations)


def _maybe_truncate(violations: list[str]) -> list[str]:
    """If violations exceed MAX_VIOLATIONS_PER_FILE, truncate and add a summary line."""
    if len(violations) > MAX_VIOLATIONS_PER_FILE:
        extra = len(violations) - MAX_VIOLATIONS_PER_FILE
        truncated = violations[:MAX_VIOLATIONS_PER_FILE]
        truncated.append(f"  … and {extra} more violations truncated")
        return truncated
    return violations


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> int:
    # Allow an explicit commands_dir argument for pre-flight testing
    if len(sys.argv) > 1:
        commands_dir = Path(sys.argv[1]).expanduser().resolve()
    else:
        commands_dir = REPO / "commands"

    if not commands_dir.is_dir():
        print("no command files found, skipping")
        return 0

    # Collect task_*.md files only — skip _contract.md, README.md, _shared/*, non-task_ files
    task_files = sorted(
        p
        for p in commands_dir.glob("task_*.md")
        if p.is_file()
        # Exclude any file that starts with _ (already handled by task_* glob, but be explicit)
    )

    if not task_files:
        print("no command files found, skipping")
        return 0

    all_violations: list[str] = []
    ok_count = 0

    # Use the parent of commands_dir as the display base for messages
    display_base = commands_dir.parent

    for path in task_files:
        file_violations = lint_file(path, base=display_base)
        if file_violations:
            all_violations.extend(file_violations)
        else:
            try:
                rel = str(path.relative_to(display_base))
            except ValueError:
                rel = str(path)
            print(f"OK: {rel}")
            ok_count += 1

    for v in all_violations:
        print(v)

    if all_violations:
        # Count actual violation lines (exclude truncation markers starting with whitespace)
        violation_files = len(
            {v.split(":")[0] for v in all_violations if not v.startswith(" ")}
        )
        print(
            f"\n{violation_files} file(s) with violations, {ok_count} OK."
        )
        return 1

    print(f"All {ok_count} file(s) OK.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"internal error: {exc}", file=sys.stderr)
        sys.exit(2)
