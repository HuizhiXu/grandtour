from pathlib import Path
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
RUNTIME = ROOT / "assets/game/runtime"
SHARE = ROOT / "assets/share"
QA = ROOT / "dist/asset-qa"
RUNTIME.mkdir(parents=True, exist_ok=True)
SHARE.mkdir(parents=True, exist_ok=True)
QA.mkdir(parents=True, exist_ok=True)
RESAMPLE = Image.Resampling.LANCZOS


def read_rgba(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    alpha = image.getchannel("A")
    # Remove faint color-key/antialias fringe without changing the painted subject.
    alpha = alpha.point(lambda value: value if value >= 18 else 0)
    alpha = alpha.filter(ImageFilter.MinFilter(13))
    image.putalpha(alpha)
    return image


def make_frame(sheet: Image.Image, col: int, row: int) -> Image.Image:
    cell_width = sheet.width // 4
    cell_height = sheet.height // 4
    tile = sheet.crop((col * cell_width, row * cell_height, (col + 1) * cell_width, (row + 1) * cell_height))
    alpha = tile.getchannel("A")
    bbox = alpha.getbbox()
    canvas = Image.new("RGBA", (128, 160), (0, 0, 0, 0))
    if bbox is None:
        return canvas
    subject = tile.crop(bbox)
    target_height = 148
    target_width = max(1, min(104, round(subject.width * target_height / subject.height)))
    subject = subject.resize((target_width, target_height), RESAMPLE)
    x = (128 - subject.width) // 2
    y = 158 - subject.height
    canvas.alpha_composite(subject, (x, y))
    return canvas


def make_atlas(source: Path, destination: Path) -> Image.Image:
    sheet = read_rgba(source)
    atlas = Image.new("RGBA", (512, 640), (0, 0, 0, 0))
    for row in range(4):
        for col in range(4):
            frame = make_frame(sheet, col, row)
            atlas.alpha_composite(frame, (col * 128, row * 160))
    atlas.save(destination, optimize=True)
    return atlas


def make_prop(source: Path, destination: Path) -> Image.Image:
    image = read_rgba(source)
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise RuntimeError(f"No visible alpha content in {source}")
    subject = image.crop(bbox)
    subject.thumbnail((112, 148), RESAMPLE)
    canvas = Image.new("RGBA", (128, 160), (0, 0, 0, 0))
    canvas.alpha_composite(subject, ((128 - subject.width) // 2, 158 - subject.height))
    canvas.save(destination, optimize=True)
    return canvas


def make_scene(source: Path, destination: Path) -> None:
    image = Image.open(source).convert("RGB").resize((1600, 900), RESAMPLE)
    image.save(destination, "JPEG", quality=91, optimize=True, progressive=True, subsampling=0)


def make_contrast_preview(atlas_path: Path, destination: Path) -> None:
    atlas = Image.open(atlas_path).convert("RGBA")
    tile_w, tile_h = 128, 160
    swatch_w, swatch_h = 150, 178
    result = Image.new("RGB", (swatch_w * 4, swatch_h * 4), "white")
    for row in range(4):
        for col in range(4):
            x, y = col * swatch_w, row * swatch_h
            color_left = (245, 238, 221) if (row + col) % 2 == 0 else (47, 78, 59)
            color_right = (47, 78, 59) if (row + col) % 2 == 0 else (245, 238, 221)
            tile = Image.new("RGB", (swatch_w, swatch_h), color_left)
            right = Image.new("RGB", (swatch_w // 2, swatch_h), color_right)
            tile.paste(right, (swatch_w // 2, 0))
            frame = atlas.crop((col * tile_w, row * tile_h, (col + 1) * tile_w, (row + 1) * tile_h))
            frame = frame.resize((128, 160), RESAMPLE)
            tile_rgba = tile.convert("RGBA")
            tile_rgba.alpha_composite(frame, ((swatch_w - 128) // 2, (swatch_h - 160) // 2))
            result.paste(tile_rgba.convert("RGB"), (x, y))
    result.save(destination, optimize=True)


traveler = make_atlas(ROOT / "assets/game/characters/traveler-watercolor-sheet.png", RUNTIME / "traveler-atlas.png")
photographer = make_atlas(ROOT / "assets/game/characters/photographer-watercolor-sheet-v2.png", RUNTIME / "photographer-atlas.png")
photographer.crop((0, 0, 128, 160)).save(RUNTIME / "photographer-npc.png", optimize=True)
make_prop(ROOT / "assets/game/props/intro-sign-clean.png", RUNTIME / "intro-sign.png")
make_prop(ROOT / "assets/game/props/old-mailbox-clean.png", RUNTIME / "old-mailbox.png")
make_scene(ROOT / "assets/game/scenes/saigon-exterior.png", RUNTIME / "saigon-exterior.jpg")
make_scene(ROOT / "assets/game/scenes/post-office-interior.png", RUNTIME / "post-office-interior.jpg")

# Recognizable stamp-sized crop of the real landmark's central clock and arched entrance.
exterior = Image.open(ROOT / "assets/game/scenes/saigon-exterior.png").convert("RGB")
icon = exterior.crop((960, 0, 1600, 640)).resize((512, 512), RESAMPLE)
icon.save(SHARE / "favicon.png", optimize=True)

# Preserve every generated cover detail by reducing resolution without cropping.
og_source = Image.open(SHARE / "og-cover.png").convert("RGB").resize((1200, 675), RESAMPLE)
og_source.save(SHARE / "og.png", optimize=True)

make_contrast_preview(RUNTIME / "traveler-atlas.png", QA / "traveler-contrast.png")
make_contrast_preview(RUNTIME / "photographer-atlas.png", QA / "photographer-contrast.png")
print("Prepared runtime art:")
for path in sorted(RUNTIME.iterdir()):
    print(f"- {path.relative_to(ROOT)} ({path.stat().st_size // 1024} KB)")
for path in [SHARE / "favicon.png", SHARE / "og.png"]:
    print(f"- {path.relative_to(ROOT)} ({path.stat().st_size // 1024} KB)")
