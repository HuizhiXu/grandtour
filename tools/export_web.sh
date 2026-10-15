#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
OUTPUT_DIR="$PROJECT_DIR/dist/web"
mkdir -p "$OUTPUT_DIR"
"$GODOT_BIN" --headless --editor --import --path "$PROJECT_DIR"
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release Web "$OUTPUT_DIR/index.html"
touch "$OUTPUT_DIR/.nojekyll"
echo "Web export ready: $OUTPUT_DIR/index.html"
