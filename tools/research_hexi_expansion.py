"""Download selected official-photo candidates for the requested 29-stop revision."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.parse import urlparse
import hashlib
import json
import requests
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/hexi-art"
CHOICES = [
    ("hexi_zhengning_market", "zhengning-captioned-v2", 12),
    ("hexi_wushaoling", "wushaoling-v2", 0),
    ("hexi_baita_temple", "baita-v2", 1),
    ("hexi_south_gate", "wuwei-tips-v2", 6),
    ("hexi_kumarajiva_temple", "poetry-v2", 26),
    ("hexi_xixia_museum", "museums-v2", 3),
    ("hexi_dayun_bell_tower", "wuwei-guide-v2", 5),
    ("hexi_haizang_temple", "poetry-v2", 25),
    ("hexi_jinta_temple", "jinta-v2", 9),
    ("hexi_zhenyuan_tower", "zhenyuan-v2", 19),
    ("hexi_dunhuang_market", "dunhuang-market-v2", 0),
    ("hexi_west_thousand_buddha", "west-intro-v2", 3),
]


def fetch(choice):
    stop_id, key, index = choice
    page = json.loads((BASE / "references" / f"{key}-images.json").read_text())
    photo = next(p for p in page["photos"] if p["index"] == index)
    url = photo["url"]
    response = requests.get(url, timeout=30, headers={"User-Agent": "Mozilla/5.0"})
    response.raise_for_status()
    suffix = Path(urlparse(url).path.split("&", 1)[0]).suffix.lower()
    path = BASE / "references" / f"{stop_id}-official{suffix}"
    path.write_bytes(response.content)
    with Image.open(path) as image:
        size = list(image.size)
        image.verify()
    return {"id": stop_id, "page": page["page"], "photo": url,
            "reference": path.relative_to(ROOT).as_posix(), "size": size,
            "reference_sha256": hashlib.sha256(response.content).hexdigest(),
            "caption": photo.get("following", []), "review": "pending visual review"}


if __name__ == "__main__":
    with ThreadPoolExecutor(max_workers=6) as pool:
        results = list(pool.map(fetch, CHOICES))
    (BASE / "expansion-references-v2.json").write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    for result in results:
        print(result["id"], result["size"])
