"""Apply the user-approved 29-stop itinerary, preserving existing scene IDs."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/hexi-art"
plan = json.loads((BASE / "itinerary-v2.json").read_text())
catalog_path = ROOT / "scripts/game/hexi_catalog.gd"
old_text = catalog_path.read_text(encoding="utf-8-sig")
previous = json.loads(old_text.split("const STOPS: Dictionary = ", 1)[1])
routes, stops = [], {}
for city in plan["cities"]:
    ids = []
    for stop_id, title in city["stops"]:
        stop = previous.get(stop_id, {}).copy()
        stop.update(plan["new_stops"].get(stop_id, {}))
        stop.update(title=title, scene=stop_id, region="甘肃 · " + city["city"], observation_only=True)
        stops[stop_id] = stop
        ids.append(stop_id)
    routes.append({"journey": "hexi", "title": city["city"] + " · 向西旅行", "tab": city["city"],
                   "subtitle": " → ".join(title for _, title in city["stops"]), "note": city["note"], "stops": ids})
assert len(stops) == 29
assert not set(plan["removed_from_journey"]) & set(stops)
text = "extends RefCounted\n## User-specified 29-stop itinerary; official-photo provenance: docs/hexi-art/production-v2.json.\n\n"
text += "const ROUTES: Array[Dictionary] = " + json.dumps(routes, ensure_ascii=False, indent="\t") + "\n\n"
text += "const STOPS: Dictionary = " + json.dumps(stops, ensure_ascii=False, indent="\t") + "\n"
catalog_path.write_text(text, encoding="utf-8")
print("Updated 5 cities and 29 stops in the user's exact order")
