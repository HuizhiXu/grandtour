"""Prepare the second stop's runtime backgrounds without changing stop one."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]

for name in ("independence-palace", "independence-palace-hall"):
    source = ROOT / "assets/game/scenes" / f"{name}.png"
    destination = ROOT / "assets/game/runtime" / f"{name}.jpg"
    image = Image.open(source).convert("RGB")
    image = image.resize((1600, 900), Image.Resampling.LANCZOS)
    image.save(destination, quality=91, optimize=True, progressive=True, subsampling=0)
    print(f"{destination.relative_to(ROOT)}: {destination.stat().st_size} bytes")
