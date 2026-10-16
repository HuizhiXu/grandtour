"""Prepare unique tour backgrounds; do not modify existing palace/post office art."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
for source in sorted((ROOT / "assets/game/scenes").glob("tour-*.png")):
    destination = ROOT / "assets/game/runtime" / (source.stem + ".jpg")
    image = Image.open(source).convert("RGB").resize((1600, 900), Image.Resampling.LANCZOS)
    image.save(destination, quality=89, optimize=True, progressive=True, subsampling=0)
    print(f"{destination.relative_to(ROOT)}: {destination.stat().st_size} bytes")
