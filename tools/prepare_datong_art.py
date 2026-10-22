"""Encode the approved Datong paintings for the playable export."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
STOPS = (
    "datong_city_wall", "datong_huayan", "datong_shanhua",
    "datong_nine_dragon_wall", "datong_yungang",
    "datong_hanging_temple", "yingxian_wooden_pagoda",
)

if __name__ == "__main__":
    for stop in STOPS:
        source = ROOT / "assets/game/scenes" / f"{stop}-v1.png"
        destination = ROOT / "assets/game/runtime" / f"tour-{stop}.jpg"
        with Image.open(source) as image:
            image.convert("RGB").resize((1600, 900), Image.Resampling.LANCZOS).save(
                destination, quality=91, optimize=True, progressive=True, subsampling=0
            )
        print(f"{destination.relative_to(ROOT)}: {destination.stat().st_size} bytes")
