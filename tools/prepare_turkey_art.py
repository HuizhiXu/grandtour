"""Prepare Turkey photo references, paintings and their reproducible provenance."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.parse import urljoin
import argparse
import hashlib
import json
import re
import requests
from PIL import Image, ImageOps, ImageDraw
from research_turkey import PAGES

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "docs/turkey-art"
MANIFEST = ART / "production-v1.json"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def references():
    itinerary = json.loads((ART / "itinerary.json").read_text())
    entries = []
    for region in itinerary["regions"]:
        for stop in region["stops"]:
            key, alt = stop["reference_page"], stop["reference_alt"]
            images = json.loads((ART / "references" / f"{key}-images.json").read_text())
            candidates = [im for im in images if im.get("alt") == alt] if alt else []
            if not candidates:
                print("NEEDS_SELECTION", stop["id"])
                continue
            entry = dict(stop, region=region["tab"], page=PAGES[key], photo=urljoin(PAGES[key], candidates[0]["src"]))
            entries.append(entry)
    save_references(entries)


def save_references(entries):
    def fetch(entry):
        path = ART / "references" / (entry["id"] + "-official.jpg")
        if not path.exists():
            response = requests.get(entry["photo"], timeout=45)
            response.raise_for_status()
            path.write_bytes(response.content)
        with Image.open(path) as image:
            entry["reference_size"] = list(image.size)
        entry["reference"] = path.relative_to(ROOT).as_posix()
        entry["reference_sha256"] = digest(path)
        entry["output"] = "assets/game/scenes/" + entry["id"] + "-v1.png"
        entry["runtime"] = "assets/game/runtime/tour-" + entry["id"] + ".jpg"
        return entry
    with ThreadPoolExecutor(max_workers=6) as pool:
        entries = list(pool.map(fetch, entries))
    data = {"journey": "土耳其", "date": "2026-10-23", "tool": "image_gen (built-in)", "style_reference": "assets/game/runtime/tour-datong_hanging_temple.jpg", "art_policy": "Each painting uses its attached official photograph for content and geometry, and the existing painting for style only. Ruins remain ruins; observation panoramas have no invented walkways. Illustrations are artistic interpretations, not official photography or archaeological reconstructions.", "stops": entries}
    MANIFEST.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print("References saved:", len(entries))


def sheets(mode):
    entries = json.loads(MANIFEST.read_text())["stops"]
    out = ROOT / "captures/turkey"
    out.mkdir(parents=True, exist_ok=True)
    for offset in range(0, len(entries), 6):
        sheet = Image.new("RGB", (1440, 930), "#f7f2e7")
        draw = ImageDraw.Draw(sheet)
        for i, entry in enumerate(entries[offset:offset + 6]):
            key = "runtime" if mode == "paintings" else "reference"
            path = ROOT / entry[key]
            if not path.exists():
                continue
            with Image.open(path) as image:
                preview = ImageOps.contain(image.convert("RGB"), (704, 275))
                x, y = i % 2 * 720, i // 2 * 310
                sheet.paste(preview, (x + (720 - preview.width) // 2, y + 30 + (275 - preview.height) // 2))
                draw.text((x + 8, y + 8), entry["id"], fill="#304538")
        sheet.save(out / f"{mode}-{offset // 6 + 1}.jpg", quality=92)


def encode():
    data = json.loads(MANIFEST.read_text())
    missing = [stop["output"] for stop in data["stops"] if not (ROOT / stop["output"]).exists()]
    if missing:
        raise FileNotFoundError("Missing final paintings: " + ", ".join(missing))
    for stop in data["stops"]:
        source, target = ROOT / stop["output"], ROOT / stop["runtime"]
        if not source.exists():
            print("PENDING", stop["id"])
            continue
        with Image.open(source) as image:
            image.convert("RGB").resize((1600, 900), Image.Resampling.LANCZOS).save(target, quality=91, optimize=True, progressive=True, subsampling=0)
        stop["source_sha256"] = digest(source)
        stop["runtime_sha256"] = digest(target)
        print(stop["id"], target.stat().st_size)
    MANIFEST.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def catalog():
    itinerary = json.loads((ART / "itinerary.json").read_text())
    routes, stops = [], {}
    for region in itinerary["regions"]:
        routes.append({"journey": "turkey", "title": region["title"], "tab": region["tab"], "subtitle": " → ".join(stop["title"] for stop in region["stops"]), "note": region["note"], "stops": [stop["id"] for stop in region["stops"]]})
        for stop in region["stops"]:
            stops[stop["id"]] = {"title": stop["title"], "scene": stop["id"], "region": region["tab"], "area": stop["area"], "observation_only": not stop.get("walk", False), "info": stop["info"]}
    source = 'extends RefCounted\n## User-specified 30-stop itinerary. Sources: docs/turkey-art/production-v1.json.\n\n'
    source += 'const ROUTES: Array[Dictionary] = ' + json.dumps(routes, ensure_ascii=False, indent="\t") + '\n\n'
    source += 'const STOPS: Dictionary = ' + json.dumps(stops, ensure_ascii=False, indent="\t") + '\n'
    (ROOT / "scripts/game/turkey_catalog.gd").write_text(source, encoding="utf-8")


def finalize():
    data = json.loads(MANIFEST.read_text())
    receipts = {receipt["id"]: receipt for line in (ART / "approved-receipts.jsonl").read_text(encoding="utf-8-sig").splitlines() if line.strip() for receipt in [json.loads(line)]}
    itinerary = json.loads((ART / "itinerary.json").read_text())
    stop_data = {stop["id"]: stop for region in itinerary["regions"] for stop in region["stops"]}
    assert len(receipts) == 30
    for stop in data["stops"]:
        receipt = receipts[stop["id"]]
        stop.update({key: receipt[key] for key in ("generated_source", "prompt", "output")})
        stop["walk"] = stop_data[stop["id"]].get("walk", False)
        stop["info"] = stop_data[stop["id"]]["info"]
        stop["photo"] = stop["photo"].split("?")[0]
        stop["visual_review"] = "Institutional photo and completed painting individually inspected; ground restricted to calibrated existing surfaces." if stop["walk"] else "Institutional photo and completed painting individually inspected; observation panorama."
    data["style_reference"] = "assets/game/runtime/saigon-exterior.jpg"
    data["art_policy"] = "Original Saigon post office is the fixed style reference for every painting. Institutional photographs define landmark features; framing and light are illustrated interpretations. No generated scene is used as the next scene's style reference. Ruins remain ruins. Existing clear ground is individually calibrated; cliffs, water, rail tracks and elevated ruins remain observation views. Illustrations are not surveyed reconstructions or current operational information."
    data["stops"][5]["source_note"] = "Station facade based on the historical photograph preserved on METU's institutional page; restrained color is interpretive, not a claim about the present station."
    MANIFEST.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    encode()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--references", action="store_true")
    parser.add_argument("--catalog", action="store_true")
    parser.add_argument("--finalize", action="store_true")
    parser.add_argument("--sheets", choices=("references", "paintings"))
    args = parser.parse_args()
    if args.finalize:
        finalize()
    elif args.catalog:
        catalog()
    elif args.references:
        references()
    elif args.sheets:
        sheets(args.sheets)
    else:
        encode()
