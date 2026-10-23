"""Download only explicitly selected photographs from archived official pages."""
from concurrent.futures import ThreadPoolExecutor
from io import BytesIO
from pathlib import Path
from urllib.parse import urlparse
import hashlib
import json
import requests
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "docs/hexi-art/references"


def download(selection):
    doc = json.loads((DEST / (selection["page_key"] + "-images.json")).read_text())
    photo = next(p for p in doc["photos"] if p["index"] == selection["index"])
    url = photo["url"]
    assert "text_to_image" not in url and "mchost.guru" not in url, "Generated images are not site photographs"
    suffix = Path(urlparse(url).path).suffix.lower()
    if suffix not in (".jpg", ".jpeg", ".png", ".webp"):
        suffix = ".jpg"
    path = DEST / (selection["id"] + "-official" + suffix)
    try:
        if not path.exists():
            response = requests.get(url, headers={"User-Agent": "Mozilla/5.0", "Referer": doc["page"]}, timeout=30)
            response.raise_for_status()
            Image.open(BytesIO(response.content)).verify()
            path.write_bytes(response.content)
        with Image.open(path) as image:
            size = list(image.size)
        return {"id": selection["id"], "page": doc["page"], "photo": url, "reference": str(path.relative_to(ROOT)), "size": size, "caption": photo.get("following", [])[:1], "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
    except Exception as exc:
        return {"id": selection["id"], "photo": url, "error": str(exc)}


if __name__ == "__main__":
    selections = json.loads((ROOT / "docs/hexi-art/reference-selections.json").read_text())
    with ThreadPoolExecutor(max_workers=5) as pool:
        results = list(pool.map(download, selections))
    (ROOT / "docs/hexi-art/official-references.json").write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    for result in results:
        print(result["id"], result.get("size") or result.get("error"))
