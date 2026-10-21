#!/usr/bin/env python3
"""Report the exact downloadable Godot pack, engine and aggregate Web build sizes."""
from pathlib import Path
import sys

root = Path(sys.argv[1])
assert root.is_dir(), root
files = [p for p in root.iterdir() if p.is_file()]
for path in sorted(files, key=lambda p: p.stat().st_size, reverse=True):
    print(f"[web-size] {path.name}: {path.stat().st_size / (1024 * 1024):.2f} MiB")
total = sum(p.stat().st_size for p in files)
print(f"[web-size] Uncompressed total: {total / (1024 * 1024):.2f} MiB")
packs = list(root.glob("*.pck"))
assert len(packs) == 1, "Expected exactly one Godot pack"
if packs[0].stat().st_size > 90 * 1024 * 1024:
    print("[web-size] WARNING: Godot resource pack still exceeds 90 MiB")
