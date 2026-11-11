# Changelog

## 2026-11-11 — `feature/add-new-hotkeys` (vs `master`)

Hotkey port from `bmnielsen/dgant openbw-replay-viewer v1.4` to CherryVis.

- `cvis-hotkeys.diff` (new): patch for `replays/static/replays/viewer/infobar.js`
  - `A` / `D`: double / halve playback speed (`U` kept as a faster alias)
  - `Z` / `X` / `C` / `V`: jump -30s / -10s / +10s / +30s (`B` also +30s, v1.2 compat); note: `Z` changes meaning from "slower" to "-30s"
  - `Q` / `W` / `E` / `R`: pause, then jump -10 / -1 / +1 / +10 frames
  - Arrow keys: camera pan via `Module.get_screen_info` / `set_screen_center_position` (`Shift` = larger step); workaround for disabled SDL keyboard in the old WASM build
  - `G`: graphs (alongside legacy `5`), `SELECT` added to ignored inputs, `play_slower()` lower bound at `1/128`
- `Dockerfile`: appended `COPY` + `git apply` step for `cvis-hotkeys.diff`
- `README.md`: Hotkeys section
