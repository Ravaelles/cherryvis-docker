#!/bin/sh
# CherryVis fix verification.
#
# Fails the build loudly when a committed fix is missing, so upstream drift
# is caught at build time instead of silently shipping a regression.
# Run from the cherryvis source root:
#   sh /tmp/verify_fixes.sh
#
# Single Responsibility: this script only verifies, it never modifies.
# Usage: verify_fixes.sh [--audit]
#   no args  - blocking checks for committed fixes (non-zero exit on failure)
#   --audit  - informational status of every known fix, always exits zero

ROOT="${CVIS_SRC:-$(pwd)}"
FAIL=0

check_present() {
  file="$1"
  marker="$2"
  label="$3"
  if grep -q "$marker" "$ROOT/$file" 2>/dev/null; then
    echo "PASS: $label"
  else
    echo "FAIL: $label (marker '$marker' not found in $file)"
    FAIL=1
  fi
}

check_absent() {
  file="$1"
  marker="$2"
  label="$3"
  if grep -q "$marker" "$ROOT/$file" 2>/dev/null; then
    echo "FAIL: $label (marker '$marker' still present in $file)"
    FAIL=1
  else
    echo "PASS: $label"
  fi
}

echo "Verifying CherryVis fixes in $ROOT"

# Modern zstd API compat (cvis-views-zstd-compat.diff).
check_present "replays/views.py" "zstandard.ZstdDecompressor" "zstd decompressor API"

# Silent BW<->CP matching console (cvis-matching-no-console.diff).
check_absent "replays/static/replays/cdb/cvis_dbg_matching.js" "Unable to match" "matching console silenced"

# Hotkeys ported from openbw-replay-viewer v1.4 (cvis-hotkeys.diff).
check_present "replays/static/replays/viewer/infobar.js" "jump_seconds" "hotkey time jumps"
check_present "replays/static/replays/viewer/infobar.js" "pan_camera" "hotkey camera pan"

# Dark mode toggle (cvis-darkmode.diff).
check_present "replays/templates/replays/index.html" "cvis-theme-toggle" "dark mode toggle wiring"
check_present "replays/static/replays/darkmode.css" 'input\[type="text"\]' "dark mode stylesheet"
check_present "replays/static/replays/darkmode.js" "CvisThemeManager" "dark mode controller"

# Bottom info dock (cvis-bottom-dock.diff).
check_present "replays/templates/replays/resources_and_time_controls.html" "bottom-info-dock" "dock markup"
check_present "replays/static/replays/viewer/infobar.css" "bottom-info-dock" "dock styles"
check_present "replays/static/replays/viewer/infobar.js" "move_info_tab_to_dock" "dock relocation"
check_present "replays/static/replays/viewer/infobar.js" "update_tech_tab" "merged Tech tab"
check_present "replays/templates/replays/game_area.html" ">Tech<" "Tech tab label"

# Track-on-select in debugger sidebar (cvis-track-select.diff).
check_present "replays/static/replays/cdb/cvis_dbg_lib.js" "cvis_activate_tracked_tab" "tracked tab activation"
check_present "replays/static/replays/cdb/cvis_dbg_unitslist.js" "cvis_activate_tracked_tab" "auto-track on select"

# Narrow debugger sidebar (cvis-sidebar-width.diff).
check_present "replays/static/replays/layout.css" "width: 25vw" "debugger sidebar width"

if [ "$1" = "--audit" ]; then
  echo ""
  echo "Audit (informational, never fails):"
  echo "- sound fix: SKIPPED (needs WASM rebuild with SDL_mixer; binaries are not committed)"
  if grep -q "Mix_OpenAudio" "$ROOT/replays/static/replays/viewer/test.wasm" 2>/dev/null; then
    echo "- sound build: PRESENT in this image (test.wasm links mixer)"
  else
    echo "- sound build: ABSENT in this image (expected until the rebuild recipe lands)"
  fi
  exit 0
fi

if [ "$FAIL" -ne 0 ]; then
  echo "Fix verification FAILED."
  exit 1
fi
echo "All fix checks passed."
