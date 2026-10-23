"""Bind every final painting prompt to a visually reviewed official photograph."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/hexi-art"
references = json.loads((BASE / "official-references.json").read_text())
selected = {entry["id"]: entry for entry in references if not entry["id"].startswith("candidate-")}
# The scenic-area overview supplies this view; the later visit report is unrelated.
dafo = json.loads((BASE / "references/dafo-images.json").read_text())
selected["hexi_zhangye_dafo"] = {"id": "hexi_zhangye_dafo", "page": dafo["page"], "photo": dafo["photos"][19]["url"], "reference": "docs/hexi-art/references/hexi_zhangye_dafo-official.png"}
selected["hexi_mogao"] = {"id": "hexi_mogao", "page": "https://www.dha.ac.cn/info/1425/3648.htm", "photo": "https://www.dha.ac.cn/__local/5/F2/44/DC2D6A0268E2AF8133F301D7D4D_F0D93E28_CD142.png", "reference": "docs/hexi-art/references/mogao-nine-storey.png"}

prompt = """Use case: illustration-story. Produce ONE refined full-bleed 16:9 landscape travel-book painting for The Grand Tour.
Image 1 is the STYLE REFERENCE ONLY: tiny warm-brown architectural ink lines, delicate precise structure and materials, polished luminous transparent watercolor, subtle ivory paper grain, cool gray-lavender shadows, natural restrained mineral color, sage/olive foliage. Do not copy its buildings or terrain.
Image 2 is the AUTHORITATIVE OFFICIAL REAL-SITE PHOTOGRAPH for {title}. The human user expressly requires this actual photograph as the factual basis. Repaint its photographed scene in Image 1's medium. Preserve the subject's exact silhouette, proportions, number and shape of roofs/spans/openings, structural arrangement, existing damage, vegetation, water, slopes, distances and camera direction. Geometry and actual scene content come from Image 2, never from imagination or from the style reference. Do not reconstruct ruins or substitute a generic temple. Do not add a walkway, plaza, bridge, pagoda, mountain or building missing from the photograph. Do not turn water, slopes or stairs into walkable paving.
Reframe carefully to landscape while keeping the photographed landmark complete and recognizable; use only visible environmental continuations or quiet watercolor paper/sky, not invented structures. Keep the reference's actual season, snow and time of day. Translate overly saturated photographic tones into natural watercolor without altering the landform. Remove tourists and graphic overlays; do not reproduce press logos or watermarks. Real architectural plaques may be understated as painted details without new lettering. No added characters, captions, UI, decorative titles, frame, collage, fantasy redesign, heavy outlines, photorealistic filter or 3D render. One coherent painting. {note}"""
notes = {
    "hexi_gansu_museum": "This is a museum-object study. Keep the bronze horse's exact photographed three-quarter pose, airborne legs, small bird under its supporting hoof, green patina and actual neutral background. No invented gallery architecture.",
    "hexi_zhongshan_bridge": "Keep the official photograph's ELEVATED diagonal bridge view and the real city/hillside behind. Do not replace it with an imagined ground-level promenade.",
    "hexi_baita_mountain": "Keep the official aerial view looking DOWN from the white pagoda compound toward the Yellow River and city. No new mountain-top palace.",
    "hexi_yellow_river_mother": "Keep the actual mother's sculpted face and headscarf, reclining pose, child placement and relief-patterned stone base. Remove visitors only; no new body pose or background river outside the photographed view.",
    "hexi_leitai": "Preserve the real contemporary enlarged bronze horse-and-chariot ceremonial array, central horse, gate and terraces shown. These are the existing scenic-site display, not imagined Han-era restoration.",
    "hexi_wuwei_confucian_temple": "The photo shows the real LINGXING GATE, its three bays, blue-green brackets, red columns, foreground stone bridge railing and red ribbons. Do not substitute a temple hall.",
    "hexi_wuwei_museum": "Faithfully preserve the photograph's actual pale green glass-clad modern facade, white portal frame and entrance steps; do not replace it with a conjectural bronze perforated cube.",
    "hexi_pingshanhu": "This is the real aerial canyon and ravine network viewed almost straight down; retain its winding landforms and viewpoint, without inventing a horizon or sky.",
    "hexi_zhangye_dafo": "This is the scenic area's official waterside architecture view: preserve the elaborate central timber facade, side pavilions, foreground pond and their reflections. Do not call or redesign it as the main Buddha hall.",
    "hexi_first_beacon": "Keep the photographed existing low eroded earth ruin and public protective fence; do not invent a restored tower or a canyon absent from this view.",
    "hexi_mogao": "Keep the official Nine-storey Building's exact narrow facade and eave count attached to its cliff, with the photographed trees. No exposed outdoor Buddha.",
    "hexi_crescent_lake": "Preserve the reference's ground-level autumn view across reeds and water toward the pavilion and dunes. Do not replace it with an invented aerial crescent shape.",
    "hexi_yang_pass": "This is the correctly identified tiny Yangguan beacon on a low distant ridge backed by snow mountains and foreground poplars, not the Yumen Pass rectangular castle. Preserve that scale and landscape."
}

manifest = json.loads((BASE / "production-v1.json").read_text())
catalog_text = (ROOT / "scripts/game/hexi_catalog.gd").read_text(encoding="utf-8-sig")
catalog_stops = json.loads(catalog_text.split("const STOPS: Dictionary = ", 1)[1].strip())
manifest["art_policy"] = "Every illustration uses its attached official real-site photograph as the geometry/content reference and the existing approved painting as style only. No text-only landmark generation, invented grounds, or reconstructed ruins. Sources and original photo hashes are retained."
manifest["rejected"] = [{"asset": "unreferenced Zhongshan Bridge draft", "reason": "Generated from text and style only; excluded from the project"}, {"source": "https://zwfw.gansu.gov.cn/wuwei/wwtslyzq/index.html", "reason": "Image URLs point to a text-to-image generation endpoint; excluded as photographic references"}, {"source": "passes photo index 3", "reason": "Shows Yumen Pass, not Yangguan; replaced with captioned Xinhua Yangguan photograph"}, {"source": "pingshanhu scenic page photo index 19", "reason": "Promotional poster replaced with a documentary landscape photograph"}]
for stop in manifest["stops"]:
    stop["info"] = catalog_stops[stop["id"]]["info"]
    reference = selected[stop["id"]]
    stop.update({key: reference[key] for key in ("reference", "photo", "page")})
    stop["reference_sha256"] = hashlib.sha256((ROOT / stop["reference"]).read_bytes()).hexdigest()
    stop["subject"] = "Official photograph geometry and composition only: " + stop["title"]
    stop["prompt"] = prompt.format(title=stop["title"], note=notes.get(stop["id"], "Faithfully repaint the official photograph, retaining its existing geography and viewpoint."))
    stop["walk"] = False
receipts_path = BASE / "generation-receipts.json"
if receipts_path.exists():
    receipts = json.loads(receipts_path.read_text())
    generated = {entry["id"]: entry for entry in receipts["generated"]}
    for stop in manifest["stops"]:
        stop["generated_source"] = generated[stop["id"]]["path"]
        stop["visual_review"] = "Official photograph and completed painting individually inspected; observation view retained."
        if stop["id"] == "hexi_wuwei_museum":
            revision = receipts["museum_revision"]
            stop["output"] = revision["output"]
            stop["revisions"] = [revision]
            stop["generated_source"] = revision["path"]
(BASE / "production-v1.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
print("Bound 20 paintings to individually reviewed official photographs.")
