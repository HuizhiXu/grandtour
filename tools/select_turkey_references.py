"""Record individually selected institutional photographs for the Turkey journey."""
import html
import json
import re
from urllib.parse import urljoin
from prepare_turkey_art import ART, MANIFEST, save_references
from research_turkey import PAGES


def select(key, alt):
    images = json.loads((ART / "references" / f"{key}-images.json").read_text())
    return html.unescape(next(image["src"] for image in images if image.get("alt") == alt))


def main():
    itinerary = json.loads((ART / "itinerary.json").read_text())
    entries = {stop["id"]: stop for stop in json.loads(MANIFEST.read_text())["stops"]}
    selected = {
        "turkey_goreme": ("cappadocia-visit", "Göreme"),
        "turkey_avanos": ("cappadocia-visit", "Avanos"),
        "turkey_uchisar": ("cappadocia-visit", "Uçhisar"),
        "turkey_goreme_museum": ("cappadocia-visit", "Göreme Açık Hava Müzesi"),
        "turkey_pigeon_valley": ("valleys", "Güvercinlik Vadisi"),
        "turkey_red_valley": ("valleys", "Kızılçukur Vadisi"),
        "turkey_innocence": ("innocence", "Masumiyet Müzesi giriş alanı"),
        "turkey_nevsehir": ("nevsehir-castle", ""),
        "turkey_perge": ("perge", "Perge Antik Kenti"),
    }
    for region in itinerary["regions"]:
        for stop in region["stops"]:
            id = stop["id"]
            if id in selected:
                key, alt = selected[id]
                photo = select(key, alt)
                if key == "innocence":
                    photo = photo.split("/v1/")[0]
                if key == "perge":
                    # Use the ministry's full colonnaded-street photograph.
                    photo = "/contents/images/ANTALYA-PERGE-G%c3%9cLCANACAR%20(16)%20kopya.jpg"
                entries[id] = dict(stop, region=region["tab"], page=PAGES[key], photo=urljoin(PAGES[key], photo))
            elif id in ["turkey_sirkeci", "turkey_antalya_airport", "turkey_side", "turkey_aspendos"]:
                key = {"turkey_sirkeci": "sirkeci-university", "turkey_antalya_airport": "airport", "turkey_side": "side-town", "turkey_aspendos": "aspendos-theatre"}[id]
                text = (ART / "references" / f"{key}-page.html").read_text()
                if id == "turkey_sirkeci":
                    photo = "Sirkeci_Bina_1950.jpg"
                elif id == "turkey_antalya_airport":
                    photo = next(p for p in re.findall(r'[^\s<>"\x27]+original\.image_file\.1341[^\s<>"\x27]*', text) if "2026_Antalya" in p and "curbside" in p)
                elif id == "turkey_aspendos":
                    photo = "https://cdn2.goturkiye.com/iconic-aspendos-1.jpg"
                else:
                    candidates = json.loads((ART / "references" / f"{key}-images.json").read_text())
                    photo = [im["src"] for im in candidates if im.get("src", "").startswith("/contents/images/")][2]
                entries[id] = dict(stop, region=region["tab"], page=PAGES[key], photo=urljoin(PAGES[key], photo))
            entries[id]["output"] = "assets/game/scenes/" + id + "-v2.png"
    ordered = [entries[stop["id"]] for region in itinerary["regions"] for stop in region["stops"]]
    # Redownload only changed selections; retain existing original photographs.
    old = {stop["id"]: stop for stop in json.loads(MANIFEST.read_text())["stops"]}
    for entry in ordered:
        path = ART / "references" / (entry["id"] + "-official.jpg")
        if path.exists() and old.get(entry["id"], {}).get("photo") != entry["photo"]:
            path.unlink()
    save_references(ordered)
    data = json.loads(MANIFEST.read_text())
    data["style_reference"] = "assets/game/runtime/saigon-exterior.jpg"
    data["user_style_approval"] = {"sample": "docs/turkey-art/previews/hagia-sophia-postoffice-v2.png", "feedback": "刚刚的那个可以", "date": "2026-10-23"}
    for stop in data["stops"]:
        stop["output"] = "assets/game/scenes/" + stop["id"] + "-v2.png"
    MANIFEST.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
