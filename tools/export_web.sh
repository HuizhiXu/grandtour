#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
OUTPUT_DIR="$PROJECT_DIR/dist/web"
BUILD_ID="${GAME_BUILD_ID:-$(git -C "$PROJECT_DIR" rev-parse --short=12 HEAD 2>/dev/null || printf local)}"
if [[ ! "$BUILD_ID" =~ ^[[:alnum:]_-]+$ ]]; then
  echo "GAME_BUILD_ID must contain only letters, digits, underscores or hyphens." >&2
  exit 1
fi
mkdir -p "$OUTPUT_DIR"
"$GODOT_BIN" --headless --editor --import --path "$PROJECT_DIR"
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release Web "$OUTPUT_DIR/game-$BUILD_ID.html"
# New asset URLs prevent a browser from reusing an older game/physics pack.
mv -- "$OUTPUT_DIR/game-$BUILD_ID.html" "$OUTPUT_DIR/index.html"
# The in-game licenses menu opens this sibling URL. Generate it on every export
# so Pages receives the notices from the same engine version and bundled fonts.
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --script res://tools/generate_web_licenses.gd -- "$OUTPUT_DIR/open-source-licenses.html"
test -s "$OUTPUT_DIR/open-source-licenses.html"
touch "$OUTPUT_DIR/.nojekyll"
echo "Web export ready: $OUTPUT_DIR/index.html"
