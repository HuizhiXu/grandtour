"""Prepare referenced paintings and review sheets without changing their content."""
from pathlib import Path
import argparse
import hashlib
import json
from PIL import Image, ImageOps, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/hexi-art/production-v1.json"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sheets(entries, prefix):
    output = ROOT / "captures/hexi"
    output.mkdir(parents=True, exist_ok=True)
    for offset in range(0, len(entries), 4):
        batch = entries[offset:offset + 4]
        canvas = Image.new("RGB", (1280, 820), "#f7f2e7")
        draw = ImageDraw.Draw(canvas)
        for index, entry in enumerate(batch):
            x, y = (index % 2) * 640, (index // 2) * 410
            path = ROOT / entry["reference"]
            with Image.open(path) as image:
                preview = ImageOps.contain(image.convert("RGB"), (624, 374))
                canvas.paste(preview, (x + (640 - preview.width) // 2, y + 27 + (374 - preview.height) // 2))
            draw.text((x + 10, y + 7), entry["id"], fill="#304538")
        path = output / f"{prefix}-{offset // 4 + 1}.jpg"
        canvas.save(path, quality=92)
        print(path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference-sheets", action="store_true")
    parser.add_argument("--art-sheets", action="store_true")
    args = parser.parse_args()
    if args.reference_sheets:
        entries = json.loads((ROOT / "docs/hexi-art/official-references.json").read_text())
        official = [entry for entry in entries if not entry["id"].startswith("candidate-") and "reference" in entry]
        if not any(entry["id"] == "hexi_mogao" for entry in official):
            official.append({"id": "hexi_mogao", "reference": "docs/hexi-art/references/mogao-nine-storey.png"})
        sheets(official, "official-references")
        sheets([entry for entry in entries if entry["id"].startswith("candidate-") and "reference" in entry], "reference-candidates")
    elif args.art_sheets:
        manifest = json.loads(MANIFEST.read_text())
        sheets([{"id": stop["id"], "reference": stop["runtime"]} for stop in manifest["stops"]], "paintings")
    else:
        manifest = json.loads(MANIFEST.read_text())
        for stop in manifest["stops"]:
            assert stop.get("reference"), f"Missing official photograph: {stop['id']}"
            source = ROOT / stop["output"]
            destination = ROOT / stop["runtime"]
            with Image.open(source) as image:
                image.convert("RGB").resize((1600, 900), Image.Resampling.LANCZOS).save(destination, quality=91, optimize=True, progressive=True, subsampling=0)
            stop["source_sha256"] = digest(source)
            stop["runtime_sha256"] = digest(destination)
            print(stop["id"], destination.stat().st_size)
        MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
