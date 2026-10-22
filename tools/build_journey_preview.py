"""Build a separate Web preview, restoring the project's native texture settings."""
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]

if __name__ == "__main__":
    engine = os.environ.get("GODOT_BIN", "godot")
    settings = {path: path.read_bytes() for path in (ROOT / "assets/game/runtime").glob("*.jpg.import")}
    environment = os.environ.copy()
    environment["GAME_OUTPUT_DIR"] = str(ROOT / "dist/datong-preview")
    environment.setdefault("GAME_BUILD_ID", "datong-20261022")
    try:
        subprocess.run([sys.executable, str(ROOT / "tools/optimize_web_textures.py")], check=True)
        subprocess.run(["bash", str(ROOT / "tools/export_web.sh")], env=environment, check=True)
    finally:
        for path, original in settings.items():
            path.write_bytes(original)
        subprocess.run([engine, "--headless", "--editor", "--import", "--path", str(ROOT)], check=True)
