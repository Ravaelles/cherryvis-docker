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

## 2026-11-11 — sound fix (live in `cvis` container, not yet committed)

No sound played because the engine was built with `-DOPENBW_NO_SDL_MIXER=1`, which stubs out every `native_sound` call in `openbw/ui/sdl2.cpp` (verified: old `test.wasm` contained zero `Mix_` symbols). Emscripten 1.38.13 has no `USE_SDL_MIXER` port, but it ships a built-in JavaScript mixer, so the fix was:

- rebuilt `test.js` / `test.wasm` with a vendored `SDL_mixer.h` on the include path and the mute define removed (same approach as the working viewer); mixer now linked (`Mix_OpenAudio` present, all replay exports intact)
- `replays/static/replays/viewer/infobar.js`: `volume_index` initialized to `0.5` (was `undefined`, which poisoned the first sound toggle), plus `cvis_unlock_audio()` that resumes the suspended `AudioContext` on first user gesture (required by the autoplay policy; `?rep=` autostart creates the context suspended), wired into document gestures, `toggle_pause()`, and canvas press
- `replays/static/replays/viewer/start.js`: one-time `[cvis] audio:` console marker to confirm the new build is loaded
- startup burst muted for the first 6 real seconds after replay load (`set_volume(0)`, then restore unless user muted), so catch-up sounds do not play all at once
- `README.md`: 🔊 bullet in Differences from upstream
