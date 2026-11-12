# cherryvis-docker
Runs CherryVis in Docker, based on https://github.com/bmnielsen/cherryvis-docker with some tweaks and updates. 
Tested on Ubuntu, October 2026.

## Differences from upstream
- ⌨️ New hotkeys, as in `bmnielsen/dgant openbw-replay-viewer` v1.4 (`A`/`D` speed, `Z`/`X`/`C`/`V` time jumps, `Q`/`W`/`E`/`R` frame steps, arrow-key camera pan)
- 📊 Production / Army / Tech strips moved to an always-visible bottom dock with auto-shrinking tiles (`Tech` merges Upgrades + Research)
- 🎯 `Track` buttons in the `Selected` sidebar auto-activate the newly opened unit/task tab
- ⏩ Replays start at 4x speed instead of 1x
- 🖼️ `.canvas-area { margin:-1px; }` edge fix
- 🔊 Sound fixed: SDL_mixer backend enabled at build time (upstream mutes it), volume defaults to 50%, audio unlocks on first interaction
- 🌙 Dark mode toggle in the navbar (`Dark mode` / `Light mode`, persisted in `localStorage`, respects `prefers-color-scheme`); text inputs, selects, and `#game-slider` use `background-color: #b1b1b1`

## Usage

1. `git clone https://github.com/Ravaelles/cherryvis-docker`
2. `cd cherryvis-docker`
3. `docker build -t cvis .`
4. `docker run -p 8770:8770 -it cvis`
5. Once the server has started up, open `localhost:8770` in a browser.

If you want to view more than just the sample replays, mount a volume with your replays when running the container, e.g. `-v <path to your replays>:/my-replays`.

## Hotkeys (as in bmnielsen/dgant openbw-replay-viewer v1.4)

- `A` / `D`: double / halve playback speed
- `Space` / `P`: pause / unpause
- `Z` / `X` / `C` / `V`: jump -30s / -10s / +10s / +30s (`B` also +30s)
- `Q` / `W` / `E` / `R`: pause, then jump -10 / -1 / +1 / +10 frames
- `Arrow keys`: pan camera (`Shift` = bigger step)
- `G` or `5`: show/hide graphs, `1`-`4`: production/army/tech tabs, `N`: progress bar
- Old aliases kept: `U` = faster, `Backspace` = -10s, `S` = sound.
