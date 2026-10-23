"""Assemble the active 29-stop source manifest without rewriting the v1 archive."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/hexi-art"
plan = json.loads((BASE / "itinerary-v2.json").read_text())
previous = json.loads((BASE / "production-v1.json").read_text())
old = {stop["id"]: stop for stop in previous["stops"]}
refs = {entry["id"]: entry for entry in json.loads((BASE / "expansion-references-v2.json").read_text())}
receipts = {entry["id"]: entry for entry in json.loads((BASE / "generation-receipts-v2.json").read_text())["generated"]}
text = (ROOT / "scripts/game/hexi_catalog.gd").read_text(encoding="utf-8-sig")
catalog = json.loads(text.split("const STOPS: Dictionary = ", 1)[1])
stops, references = [], []
for city in plan["cities"]:
    for stop_id, title in city["stops"]:
        stop = old.get(stop_id, {}).copy()
        if stop_id in refs:
            ref, receipt = refs[stop_id], receipts[stop_id]
            stop.update(id=stop_id, subject="Official photograph composition and geometry only: " + title,
                        reference=ref["reference"], page=ref["page"], photo=ref["photo"],
                        reference_sha256=ref["reference_sha256"], prompt=receipt["prompt"],
                        generated_source=receipt["path"], output=receipt["output"],
                        runtime=f"assets/game/runtime/tour-{stop_id}.jpg", walk=False,
                        visual_review="Official photograph and final watercolor individually inspected; observation panorama retained.")
            if receipt.get("revisions"):
                stop["revisions"] = receipt["revisions"]
                final = receipt["revisions"][-1]
                stop.update(output=final["output"], generated_source=final["path"])
        stop.update(title=title, city=city["city"], area=catalog[stop_id]["area"], info=catalog[stop_id]["info"])
        reference = ROOT / stop["reference"]
        assert hashlib.sha256(reference.read_bytes()).hexdigest() == stop["reference_sha256"], stop_id
        assert (ROOT / stop["output"]).is_file(), stop_id
        stops.append(stop)
        references.append({k: stop[k] for k in ("id", "title", "page", "photo", "reference", "reference_sha256")})
assert len(stops) == 29 and len(receipts) == 12
manifest = {"journey": previous["journey"], "date": plan["date"], "tool": "image_gen (built-in)",
            "art_policy": previous["art_policy"], "style_reference": previous["style_reference"],
            "itinerary": "docs/hexi-art/itinerary-v2.json", "stops": stops,
            "retired_from_journey": plan["removed_from_journey"],
            "previous_manifest": "docs/hexi-art/production-v1.json",
            "reference_review": [
                "Zhengning: rejected a general night-market illustration without a precise location caption; selected a captioned Xinhua photograph of a Zhengning Road food stall.",
                "Xixia Museum: selected the official Tangut stele object photograph rather than a text-heavy exhibition entrance panel.",
                "Dayun and Haizang: reduced invented plaque lettering to understated paint; architecture preserved.",
                "Jinta Temple: rejected the first painting's extra cave gallery; revised to match the single actual gallery in the official exterior photograph.",
                "Dunhuang night market: matched the central plaque's right-to-left characters to the official photograph."
            ]}
(BASE / "production-v2.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
(BASE / "official-references-v2.json").write_text(json.dumps(references, ensure_ascii=False, indent=2), encoding="utf-8")
print("29 active paintings bound to reviewed official reference photographs")
