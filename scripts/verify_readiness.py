#!/usr/bin/env python3
"""Public-readiness checks for the CAD automation proof package."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

EXCLUDED_DIRS = {
    ".git",
    "dist",
    "__pycache__",
    ".pytest_cache",
    ".ruff_cache",
    ".mypy_cache",
    ".venv",
    "node_modules",
}

BANNED_NAME_PARTS = [
    ".DS_Store",
    "ch" + "eat",
]

BANNED_TEXT_PATTERNS = [
    re.compile("g" + "ho_" + r"[A-Za-z0-9_]+"),
    re.compile("github" + "_pat_" + r"[A-Za-z0-9_]+"),
    re.compile("s" + "k-" + r"[A-Za-z0-9_-]{20,}"),
    re.compile("A" + "KIA" + r"[0-9A-Z]{16}"),
    re.compile(r"-----BEGIN " + r"(?:RSA |EC |OPENSSH |)" + "PRIVATE " + "KEY" + r"-----"),
    re.compile(
        re.escape(str(Path.home()))
        + r"/(?!"
        + re.escape(str(ROOT.relative_to(Path.home())))
        + r")"
    ),
]

TEXT_SUFFIXES = {
    ".css",
    ".csv",
    ".html",
    ".js",
    ".json",
    ".lsp",
    ".md",
    ".py",
    ".txt",
    ".xml",
    ".yml",
    ".yaml",
}


def iter_files() -> list[Path]:
    files: list[Path] = []
    for path in ROOT.rglob("*"):
        rel_parts = path.relative_to(ROOT).parts
        if any(part in EXCLUDED_DIRS for part in rel_parts):
            continue
        if path.is_file():
            files.append(path)
    return files


def is_text_file(path: Path) -> bool:
    return path.suffix.lower() in TEXT_SUFFIXES or path.name in {"README.md", "LICENSE"}


def main() -> int:
    failures: list[str] = []
    files = iter_files()

    for path in files:
        rel = path.relative_to(ROOT)
        rel_text = str(rel)
        lower_name = rel_text.lower()

        for banned in BANNED_NAME_PARTS:
            if banned.lower() in lower_name:
                failures.append(f"banned filename pattern {banned!r}: {rel_text}")

        if path.suffix.lower() == ".zip":
            failures.append(f"zip archive should not be committed: {rel_text}")

        if is_text_file(path):
            text = path.read_text(encoding="utf-8", errors="ignore")
            for pattern in BANNED_TEXT_PATTERNS:
                if pattern.search(text):
                    failures.append(f"banned text pattern {pattern.pattern!r}: {rel_text}")

    required = [
        "README.md",
        "index.html",
        "client-brief/CrownCastle_CAD_Automation_Technical_Alignment_Brief.html",
        "docs/runbook.md",
        "docs/sanitization-checklist.md",
        "samples/scope_sample.csv",
        "src/load_all.lsp",
    ]
    for rel in required:
        if not (ROOT / rel).is_file():
            failures.append(f"missing required file: {rel}")

    if failures:
        print("Readiness check failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(f"Readiness check passed: {len(files)} public files inspected.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
