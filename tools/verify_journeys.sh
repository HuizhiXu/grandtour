#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
cd "$PROJECT_DIR"
for suite in journey_suite tour_suite postcard_suite palace_suite exploration_suite walkable_ground_suite archie_animation_suite; do
  "$GODOT_BIN" --headless --path "$PROJECT_DIR" --script "res://test/$suite.gd"
done
"$GODOT_BIN" --headless --path "$PROJECT_DIR" res://test/test_suite.tscn
