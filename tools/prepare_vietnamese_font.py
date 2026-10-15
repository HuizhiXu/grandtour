"""Subset the bundled Vietnamese fallback from official Noto Sans variable TTF."""
import argparse
import hashlib
import json
from pathlib import Path
from fontTools import subset
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[1]
DESTINATION = ROOT / "assets/template/fonts/NotoSans-Vietnamese.subset.woff2"

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--source", type=Path, required=True)
args = parser.parse_args()
font = TTFont(args.source)
# ASCII/Latin bases, extended vowels and combining accents support both NFC
# and decomposed Vietnamese text. Preserve variable weights for all UI styles.
codepoints = set(range(0x20, 0x250)) | set(range(0x300, 0x370)) | set(range(0x1E00, 0x1F00))
required = {ord(character) for character in "Ngô Viết Thụ"}
assert required <= set(font.getBestCmap()), "Source font lacks required Vietnamese glyphs"
options = subset.Options()
options.flavor = "woff2"
options.layout_features = ["*"]
worker = subset.Subsetter(options)
worker.populate(unicodes=codepoints)
worker.subset(font)
font.flavor = "woff2"
font.save(DESTINATION)
with TTFont(DESTINATION) as result:
    assert required <= set(result.getBestCmap())
manifest = {
    "family": "Noto Sans",
    "source": "https://raw.githubusercontent.com/google/fonts/main/ofl/notosans/NotoSans%5Bwdth,wght%5D.ttf",
    "sourceSha256": hashlib.sha256(args.source.read_bytes()).hexdigest(),
    "sourceVersion": font["name"].getDebugName(5),
    "license": "OFL-1.1",
    "licenseFile": "NotoSans-OFL.txt",
    "runtimePath": str(DESTINATION.relative_to(ROOT)),
    "sha256": hashlib.sha256(DESTINATION.read_bytes()).hexdigest(),
    "size": DESTINATION.stat().st_size,
    "unicodeRanges": ["U+0020-024F", "U+0300-036F", "U+1E00-1EFF"],
    "purpose": "Bundled Vietnamese fallback after existing Figtree and Noto Sans SC; no system font dependency",
}
DESTINATION.with_suffix(".json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print(json.dumps(manifest, indent=2))
