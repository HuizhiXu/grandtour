#!/usr/bin/env python3
"""Use smaller on-disk textures for the web build without modifying source art.

Godot's lossless default re-encodes the already lossy 1600x900 JPEG scenes
as lossless WebP. Those imported .ctex textures dominate the .pck size.
The Web build can safely use Godot's lossy WebP importer instead.
It also limits imported JPEGs to the game's 1280-pixel-wide logical viewport,
reducing the uncompressed texture memory footprint on mobile Safari.

Only runtime JPEG import settings are changed, never the image files, sprites,
source artwork, or native editor import settings on the main branch.
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
RUNTIME = ROOT / "assets" / "game" / "runtime"
QUALITY = "0.78"
MAX_TEXTURE_EDGE = 1280


def main() -> None:
    imports = sorted(RUNTIME.glob("*.jpg.import"))
    if len(imports) < 40:
        raise SystemExit(f"Expected the runtime scene imports; found {len(imports)}")
    for path in imports:
        original = path.read_text(encoding="utf-8")
        updated, count = re.subn(r"(?m)^compress/mode=\d+$", "compress/mode=1", original)
        updated, quality_count = re.subn(
            r"(?m)^compress/lossy_quality=[^\n]+$",
            f"compress/lossy_quality={QUALITY}",
            updated,
        )
        updated, size_count = re.subn(
            r"(?m)^process/size_limit=\d+$",
            f"process/size_limit={MAX_TEXTURE_EDGE}",
            updated,
        )
        if count != 1 or quality_count != 1 or size_count != 1:
            raise SystemExit(f"Unexpected Godot import options: {path}")
        if updated != original:
            path.write_text(updated, encoding="utf-8")
    print(f"[web-textures] Prepared {len(imports)} JPEG scene imports (lossy WebP quality {QUALITY}, max edge {MAX_TEXTURE_EDGE}px).")


if __name__ == "__main__":
    main()
