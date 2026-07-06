#!/usr/bin/env python3
"""Replace duplicate .ps1 files with relative symlinks to a canonical copy."""
from __future__ import annotations

import hashlib
import os
import re
from collections import defaultdict
from pathlib import Path

WORKSPACE = Path("/workspace")

# Priority order for choosing canonical location (lower index = preferred)
CANONICAL_PRIORITY = [
  "Modules/",
  "src/",
  "Shared/",
  "Tools/",
  "Snippets/",
  "Reference/",
]

# Paths that should never be canonical (staging / copies)
DEPRIORITIZE_PATTERNS = [
  re.compile(r"Scripts-Random"),
  re.compile(r"[-_]RootCopy", re.I),
  re.compile(r" - Copy", re.I),
  re.compile(r"WithCopy", re.I),
  re.compile(r"old\.ps1$", re.I),
  re.compile(r"^simplefunctions", re.I),
]

# Explicit canonical overrides: duplicate path fragment -> canonical path fragment
EXPLICIT_CANONICAL = {
  "src/General/": None,  # staging — never canonical
  "Scripts-Random": None,
  "Modules/Storage/DailyDiskSpace": "Modules/Storage/DailyDiskSpace",
  "src/Computer-Info/Scripts/Get-SystemInfo.ps1": "src/Computer-Info/Scripts/Get-SystemInfo.ps1",
  "src/Active-Directory/Scripts/": "src/Active-Directory/Scripts/",
}


def file_hash(path: Path) -> str:
  h = hashlib.md5()
  with path.open("rb") as f:
    for chunk in iter(lambda: f.read(65536), b""):
      h.update(chunk)
  return h.hexdigest()


def score_path(rel: str) -> tuple:
  """Lower score = better canonical candidate."""
  deprioritize = any(p.search(rel) for p in DEPRIORITIZE_PATTERNS)
  priority = len(CANONICAL_PRIORITY)
  for i, prefix in enumerate(CANONICAL_PRIORITY):
    if rel.startswith(prefix):
      priority = i
      break
  depth = rel.count("/")
  return (1 if deprioritize else 0, priority, depth, len(rel), rel)


def choose_canonical(paths: list[Path]) -> Path:
  rels = [str(p.relative_to(WORKSPACE)).replace("\\", "/") for p in paths]
  for fragment, canonical_fragment in EXPLICIT_CANONICAL.items():
    if canonical_fragment:
      for p in paths:
        rel = str(p.relative_to(WORKSPACE)).replace("\\", "/")
        if canonical_fragment in rel or rel.endswith(canonical_fragment.lstrip("/")):
          return p
  ranked = sorted(paths, key=lambda p: score_path(str(p.relative_to(WORKSPACE)).replace("\\", "/")))
  return ranked[0]


def make_relative_symlink(target: Path, link: Path) -> None:
  rel = os.path.relpath(target, link.parent)
  if link.is_symlink() or link.exists():
    link.unlink()
  link.symlink_to(rel)


def main() -> None:
  hashes: dict[str, list[Path]] = defaultdict(list)
  for path in WORKSPACE.rglob("*.ps1"):
    if path.is_symlink():
      continue
    try:
      hashes[file_hash(path)].append(path)
    except OSError:
      continue
  for path in WORKSPACE.rglob("*.PS1"):
    if path.is_symlink():
      continue
    try:
      hashes[file_hash(path)].append(path)
    except OSError:
      continue

  linked = 0
  skipped_near = 0
  log_lines: list[str] = []

  for digest, paths in sorted(hashes.items(), key=lambda x: -len(x[1])):
    if len(paths) < 2:
      continue

    # Skip groups where files differ in size significantly (near-duplicates)
    sizes = {p.stat().st_size for p in paths}
    if len(sizes) > 1:
      skipped_near += 1
      continue

    canonical = choose_canonical(paths)
    for dup in paths:
      if dup.resolve() == canonical.resolve():
        continue
      rel_dup = str(dup.relative_to(WORKSPACE))
      rel_canon = str(canonical.relative_to(WORKSPACE))
      make_relative_symlink(canonical, dup)
      log_lines.append(f"LINK {rel_dup} -> {rel_canon}")
      linked += 1

  log_path = WORKSPACE / "docs" / "DEDUPLICATION-LOG.md"
  log_path.write_text(
    "# Deduplication Log\n\n"
    f"Created **{linked}** symlinks; skipped **{skipped_near}** near-duplicate groups (size mismatch).\n\n"
    "| Duplicate | Canonical |\n"
    "|-----------|----------|\n"
    + "\n".join(
      f"| `{line.split(' -> ')[0][5:]}` | `{line.split(' -> ')[1]}` |"
      for line in log_lines
    )
    + "\n",
    encoding="utf-8",
  )
  print(f"Symlinks created: {linked}")
  print(f"Near-duplicate groups skipped: {skipped_near}")
  print(f"Log written to {log_path}")


if __name__ == "__main__":
  main()
