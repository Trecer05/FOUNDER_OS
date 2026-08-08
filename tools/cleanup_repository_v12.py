#!/usr/bin/env python3
from __future__ import annotations

import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKIP = {".git", "Pods"}
REMOVE_DIR_NAMES = {"__pycache__"}
GENERATED_DIRS = {
    ROOT / "build",
    ROOT / ".dart_tool",
    ROOT / "ios/.symlinks",
    ROOT / "ios/Flutter/ephemeral",
    ROOT / "android/.gradle",
}
REMOVE_FILE_NAMES = {".DS_Store"}
REMOVE_SUFFIXES = {".pyc", ".tmp", ".swp", ".log"}

removed: list[str] = []

# These are generated caches only. Flutter recreates them during verification.
for generated in GENERATED_DIRS:
    if generated.exists() and generated.is_dir():
        shutil.rmtree(generated)
        removed.append(str(generated.relative_to(ROOT)) + "/")

for path in list(ROOT.rglob("*")):
    if any(part in SKIP for part in path.parts):
        continue
    try:
        if path.is_file() and (
            path.name in REMOVE_FILE_NAMES or path.suffix in REMOVE_SUFFIXES
        ):
            path.unlink()
            removed.append(str(path.relative_to(ROOT)))
        elif path.is_dir() and path.name in REMOVE_DIR_NAMES:
            shutil.rmtree(path)
            removed.append(str(path.relative_to(ROOT)) + "/")
    except FileNotFoundError:
        pass

# Remove empty untracked-looking temp directories only. Never remove source/doc dirs.
for path in sorted(ROOT.rglob("*"), key=lambda p: len(p.parts), reverse=True):
    if any(part in SKIP for part in path.parts):
        continue
    if not path.is_dir():
        continue
    if path.name.startswith((".tmp_", ".founder_v", "tmp_")):
        try:
            if not any(path.iterdir()):
                path.rmdir()
                removed.append(str(path.relative_to(ROOT)) + "/")
        except OSError:
            pass

large = []
for path in ROOT.rglob("*"):
    if any(part in SKIP for part in path.parts) or not path.is_file():
        continue
    try:
        size = path.stat().st_size
    except FileNotFoundError:
        continue
    if size > 25 * 1024 * 1024:
        large.append((size, str(path.relative_to(ROOT))))

print(f"cleanup: removed={len(removed)}")
for item in removed[:80]:
    print(f"  removed {item}")
if large:
    print("large tracked/worktree candidates (>25 MiB):")
    for size, item in sorted(large, reverse=True):
        print(f"  {size / 1024 / 1024:.1f} MiB  {item}")
else:
    print("large tracked/worktree candidates: none")
