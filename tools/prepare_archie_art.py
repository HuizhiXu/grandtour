"""Pack the approved generated Archie sheet; preserve its original RGBA artwork."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets/game/characters/archie-sheet.png"
DESTINATION = ROOT / "assets/game/runtime/archie-atlas.png"
CELL = 160
BASELINE = 154
BODY_ANCHORS = [0.36, 0.39, 0.50, 0.61]


def main():
    source = Image.open(SOURCE).convert("RGBA")
    cells = []
    for row in range(4):
        for column in range(4):
            cell = source.crop((round(column * source.width / 4), round(row * source.height / 4),
                                round((column + 1) * source.width / 4), round((row + 1) * source.height / 4)))
            # Measure the substantial subject, without treating near-transparent RGB noise as padding.
            bounds = cell.getchannel("A").point(lambda alpha: 255 if alpha >= 160 else 0).getbbox()
            if bounds is None:
                raise ValueError(f"Missing Archie in cell {row}, {column}")
            cells.append((row, column, cell.crop(bounds)))
    scale = 128.0 / max(subject.height for _, _, subject in cells)
    atlas = Image.new("RGBA", (CELL * 4, CELL * 4))
    for row, column, subject in cells:
        subject = subject.resize((round(subject.width * scale), round(subject.height * scale)), Image.Resampling.LANCZOS)
        x = round(CELL / 2 - subject.width * BODY_ANCHORS[row])
        y = BASELINE - subject.height
        if x < 0 or x + subject.width > CELL or y < 0:
            raise ValueError(f"Archie does not fit cell {row}, {column}")
        atlas.alpha_composite(subject, (column * CELL + x, row * CELL + y))
    atlas.save(DESTINATION, optimize=True)
    print(f"Packed {DESTINATION.relative_to(ROOT)}: {atlas.size}, four genuine direction rows, baseline {BASELINE}")


if __name__ == "__main__":
    main()
