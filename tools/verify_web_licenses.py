"""Check the deployed license URL and verbatim bundled font notices."""

import argparse
import json
from html.parser import HTMLParser
from pathlib import Path


class Page(HTMLParser):
    def __init__(self, source):
        super().__init__(convert_charrefs=True)
        self.blocks = []
        self.links = []
        self.in_pre = False
        self.feed(source)

    def handle_starttag(self, tag, attrs):
        if tag == "pre":
            self.blocks.append("")
            self.in_pre = True
        if tag == "a":
            self.links.append(dict(attrs).get("href"))

    def handle_endtag(self, tag):
        if tag == "pre":
            self.in_pre = False

    def handle_data(self, data):
        if self.in_pre:
            self.blocks[-1] += data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("page", type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    page = Page(args.page.read_text(encoding="utf-8"))
    assert "./" in page.links, "Missing project-relative return link"
    assert "Permission is hereby granted, free of charge" in page.blocks[0], "Missing Godot MIT text"
    inventory = json.loads(page.blocks[1])
    assert inventory and all("parts" in item for item in inventory), "Missing engine third-party notices"
    assert len(page.blocks) > 6, "Missing engine third-party license texts"
    fonts = list((root / "assets/template/fonts").rglob("*-OFL.txt"))
    assert len(fonts) == 4, "Update font coverage when adding bundled families"
    for font in fonts:
        assert font.read_text(encoding="utf-8") in page.blocks, f"Missing or altered notice: {font}"
    helper = (root / "scripts/manus/open_source_licenses.gd").read_text(encoding="utf-8")
    assert "new URL('open-source-licenses.html', window.location.href)" in helper
    assert args.page.name == "open-source-licenses.html", "Page must match the in-game URL"
    print("Verified license URL, Godot notices, four complete font licenses and return link")


if __name__ == "__main__":
    main()
