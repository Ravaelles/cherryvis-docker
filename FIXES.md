# CherryVis fixes catalog

All viewer changes live here as patch files (`cvis-*.diff`) applied in
`Dockerfile` build order. Upstream (`TorchCraftAI/scripts/cherryvis`,
`OpenBW/openbw`) is cloned fresh on every build, so anything not stored in
this repository is lost on rebuild. `verify_fixes.sh` asserts every committed
fix and fails the build loudly on upstream drift.

## Committed fixes

| Fix | Patch | Touches | Verifies via |
|-----|-------|---------|--------------|
| Modern `zstd` API compat | `cvis-views-zstd-compat.diff` | `replays/views.py` | `zstandard.ZstdDecompressor` present |
| Silent BW-CP matching log | `cvis-matching-no-console.diff` | `replays/static/replays/cdb/cvis_dbg_matching.js` | `Unable to match` absent |
| Hotkeys (openbw-replay-viewer v1.4) | `cvis-hotkeys.diff` | `replays/static/replays/viewer/infobar.js` | `jump_seconds`, `pan_camera` present |
| Dark mode toggle | `cvis-darkmode.diff` | `replays/static/replays/darkmode.css` (new), `replays/static/replays/darkmode.js` (new), `replays/templates/replays/index.html` | `cvis-theme-toggle` wired; gray `#b1b1b1` tone for `input[type="text"]`, `select`, `#game-slider` |
| Bottom info dock | `cvis-bottom-dock.diff` | `replays/templates/replays/game_area.html`, `replays/templates/replays/resources_and_time_controls.html`, `replays/static/replays/viewer/infobar.css`, `replays/static/replays/viewer/infobar.js`, `replays/static/replays/viewer/start.js` | `bottom-info-dock`, `move_info_tab_to_dock`, `update_tech_tab`, `>Tech<` |
| Track-on-select sidebar | `cvis-track-select.diff` | `replays/static/replays/cdb/cvis_dbg_lib.js`, `replays/static/replays/cdb/cvis_dbg_unitslist.js` | `cvis_activate_tracked_tab` |
| Narrow debugger sidebar | `cvis-sidebar-width.diff` | `replays/static/replays/layout.css` (`.sidebar-cdb` `30vw` -> `25vw`) | `width: 25vw` |

## Re-applying a fix after upstream moves a file

1. Fetch the upstream file and diff it against the last known good copy.
2. Keep only the hunks that belong to the fix (one fix per patch file).
3. Regenerate the patch from a clean upstream tree and re-run the full
   `git apply --check` sequence plus `verify_fixes.sh`.
4. Rebuild the image; `verify_fixes.sh` runs inside the build and fails
   loudly if a marker is missing.

## Skipped: sound fix

Out of scope by decision. It requires rebuilding `test.js`/`test.wasm`
with an SDL_mixer backend (vendored `SDL_mixer.h`, mute define removed)
plus player-side unlock handling. Built WASM binaries are deliberately not
committed. `verify_fixes.sh --audit` reports whether the running image
links the mixer (`Mix_OpenAudio` in `test.wasm`).
