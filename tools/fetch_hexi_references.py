"""Inspect primary-source pages and keep their photo URLs and context together."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.parse import urljoin
import json
import sys
import requests
from bs4 import BeautifulSoup

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "docs/hexi-art/references"


def inspect(entry):
    key, url = entry.split("=", 1)
    try:
        response = requests.get(url, timeout=22, headers={"User-Agent": "Mozilla/5.0"})
        response.raise_for_status()
        response.encoding = response.apparent_encoding
        soup = BeautifulSoup(response.text, "html.parser")
        photos = []
        for index, img in enumerate(soup.find_all("img")):
            src = img.get("data-src") or img.get("src")
            if not src or src.startswith("data:"):
                continue
            context = img.parent.get_text(" ", strip=True)
            if len(context) < 8:
                context = img.parent.parent.get_text(" ", strip=True)
            following = [p.get_text(" ", strip=True) for p in img.find_all_next(["p", "h2"], limit=3)]
            photos.append({"index": index, "url": urljoin(response.url, src), "alt": img.get("alt", ""), "context": context[:300], "following": following})
        result = {"key": key, "page": response.url, "title": soup.title.get_text() if soup.title else key, "photos": photos}
        (DEST / (key + "-page.html")).write_text(response.text, encoding="utf-8")
        (DEST / (key + "-images.json")).write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
        return result
    except Exception as exc:
        return {"key": key, "page": url, "error": str(exc)}


if __name__ == "__main__":
    DEST.mkdir(parents=True, exist_ok=True)
    with ThreadPoolExecutor(max_workers=6) as pool:
        for result in pool.map(inspect, sys.argv[1:]):
            compact = dict(result)
            compact["photos"] = [{"index": p["index"], "url": p["url"], "alt": p["alt"], "following": [s[:85] for s in p["following"]]} for p in result.get("photos", []) if not any(term in p["url"] for term in ("/images/zyxb_", "/ggbf/", "icon", "logo", "/skin/"))]
            print(json.dumps({"key": result["key"], "page": result["page"], "photos": len(result.get("photos", [])), "error": result.get("error")}, ensure_ascii=False))
