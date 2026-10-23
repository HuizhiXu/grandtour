"""Collect official destination pages and their labelled image references."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import json
import re
import html
import requests

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/turkey-art/references"
PAGES = {
    "istanbul": "https://goturkiye.com/istanbul/destinations",
    "cappadocia": "https://goturkiye.com/cappadocia/see-cappadocia",
    "nevsehir": "https://goturkiye.com/nevsehir/see",
    "izmir": "https://goturkiye.com/izmir/see",
    "antalya": "https://goturkiye.com/antalya/see",
    "cesme": "https://goturkiye.com/tr/cesme/gor",
    "bosphorus": "https://goturkiye.com/istanbul/bosphorus",
    "hagia-sophia": "https://goturkiye.com/istanbul/hagia-sophia",
    "topkapi": "https://goturkiye.com/istanbul/topkapi-palace",
    "blue-mosque": "https://goturkiye.com/istanbul/blue-mosque",
    "hippodrome": "https://goturkiye.com/istanbul/hippodrome",
    "istiklal": "https://goturkiye.com/istanbul/istiklal-caddesi-grande-rue-de-pera",
    "galata": "https://goturkiye.com/istanbul/galata-tower",
    "rumeli": "https://goturkiye.com/istanbul/rumeli-fortress",
    "innocence": "https://www.masumiyetmuzesi.org/en",
    "airport": "https://www.fraport.com/en/business-areas/international-activities/antalya-airport.html",
    "sirkeci": "https://kulturportali.gov.tr/turkiye/istanbul/gezilecekyer/stanbul-demiryolu-muzesi",
    "nevsehir-castle": "https://kulturportali.gov.tr/turkiye/nevsehir/gezilecekyer/nevsehr-kales",
    "pigeon-valley": "https://nevsehir.ktb.gov.tr/TR-365825/guvercinlik-vadisi--pigeon-valley-.html",
    "red-valley": "https://nevsehir.ktb.gov.tr/TR-365829/kizilcukur-vadisi.html",
    "perge": "https://kulturportali.gov.tr/turkiye/antalya/gezilecekyer/perge",
    "side": "https://goturkiye.com/turkishriviera/heart-of-turkish-riviera",
    "cappadocia-visit": "https://kapadokyaalan.ktb.gov.tr/cappadokia/visit-points",
    "aspendos-theatre": "https://goturkiye.com/locations/aspendos",
    "central": "https://goturkiye.com/central/touch",
    "vineyards": "https://goturkiye.com/vineyards/cappadocia-vineyard-route",
    "valleys": "https://kapadokyaalan.ktb.gov.tr/cappadokia/visit-points/valleys",
    "sirkeci-university": "https://users.metu.edu.tr/tonuk/E40003/Sirkeci/",
    "side-town": "https://www.kulturportali.gov.tr/turkiye/antalya/gezilecekyer/side-1",
}


def collect(item):
    key, url = item
    try:
        response = requests.get(url, timeout=20)
    except requests.RequestException as error:
        return {"region": key, "status": str(error), "images": []}
    images = []
    for match in re.finditer(r"<img\b[^>]*>", response.text, re.I):
        entry = dict(re.findall(r'([\w-]+)=[\"\x27]([^\"\x27]*)[\"\x27]', match.group()))
        context = response.text[max(0, match.start() - 250):match.end() + 750]
        entry["context"] = html.unescape(re.sub(r"<[^>]*>", " ", context))[:600]
        images.append(entry)
    (OUT / f"{key}-images.json").write_text(json.dumps(images, ensure_ascii=False, indent=2), encoding="utf-8")
    (OUT / f"{key}-page.html").write_text(response.text, encoding="utf-8")
    return {"region": key, "status": response.status_code, "images": images}


if __name__ == "__main__":
    import sys
    OUT.mkdir(parents=True, exist_ok=True)
    with ThreadPoolExecutor(max_workers=6) as pool:
        pages = {k: v for k, v in PAGES.items() if not sys.argv[1:] or k in sys.argv[1:]}
        for result in pool.map(collect, pages.items()):
            print(result["region"], result["status"], [(im.get("alt"), im.get("src")) for im in result["images"] if im.get("alt") not in ("Logo", "Türkiye Logo")][:16])
