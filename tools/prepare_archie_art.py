"""Pack the approved generated Archie sheet; preserve its original RGBA artwork."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
DESTINATION = ROOT / "assets/game/runtime/archie-atlas.png"
CELL = 160
BASELINE = 154
BODY_ANCHORS = [0.36, 0.39, 0.50, 0.61]


def pack(source_path, destination, columns, row_edges=None):
    source = Image.open(source_path).convert("RGBA")
    row_edges = row_edges or [round(n * source.height / 4) for n in range(5)]
    cells = []
    for row in range(4):
        for column in range(columns):
            cell = source.crop((round(column * source.width / columns), row_edges[row],
                                round((column + 1) * source.width / columns), row_edges[row + 1]))
            # Measure the substantial subject, without treating near-transparent RGB noise as padding.
            bounds = cell.getchannel("A").point(lambda alpha: 255 if alpha >= 160 else 0).getbbox()
            if bounds is None:
                raise ValueError(f"Missing Archie in cell {row}, {column}")
            cells.append((row, column, cell.crop(bounds)))
    scale = 128.0 / max(subject.height for _, _, subject in cells)
    atlas = Image.new("RGBA", (CELL * columns, CELL * 4))
    for row, column, subject in cells:
        subject = subject.resize((round(subject.width * scale), round(subject.height * scale)), Image.Resampling.LANCZOS)
        x = round(CELL / 2 - subject.width * BODY_ANCHORS[row])
        y = BASELINE - subject.height
        if x < 0 or x + subject.width > CELL or y < 0:
            raise ValueError(f"Archie does not fit cell {row}, {column}")
        atlas.alpha_composite(subject, (column * CELL + x, row * CELL + y))
    atlas.save(destination, optimize=True)
    print(f"Packed {destination.relative_to(ROOT)}: {atlas.size}, four genuine direction rows, baseline {BASELINE}")


if __name__ == "__main__":
    pack(ROOT / "assets/game/characters/archie-run-sheet.png", DESTINATION, 6, [0, 256, 488, 738, 1024])
    pack(ROOT / "assets/game/characters/archie-idle-sheet.png", ROOT / "assets/game/runtime/archie-idle-atlas.png", 4)
