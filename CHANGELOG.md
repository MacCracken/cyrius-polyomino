# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.4.0] - 2026-06-14

**M3 — modern guideline layer.** Layers the modern "feel" features on top of
the proven classic core: SRS rotation with wall kicks, a 7-bag randomiser,
hold, ghost, hard drop, a multi-piece NEXT queue, and the full guideline
scoring extensions (back-to-back, combo, T-spin). The simulation stays a
pure, deterministic integer core — every new mechanic is headless-tested
(235 assertions, up from 160); the replay/seed invariant still holds with
the 7-bag seeded. fmt + lint + vet clean. DCE binary 112,216 B (+12,144 vs
0.3.0). The render items (ghost, NEXT queue, HOLD slot) build and pixel-test
headless but still want a console playtest for *feel*.

### Added
- **`srs.cyr` — Super Rotation System wall kicks.** The documented SRS kick
  tables (a shared J/L/S/T/Z table + a distinct I table; O never kicks),
  stored already converted to the engine's row-down +y. `world_rotate` now
  tries the five kick offsets in order and commits the first that fits, so
  rotations slide off walls and floors per the guideline. Cited per
  [ADR 0001](docs/adr/0001-original-puzzle-from-observation.md);
  reference pinned in [`docs/standards/srs-rotation.md`](docs/standards/srs-rotation.md).
- **`rng.cyr` — seedable 7-bag randomiser.** Split the LCG out of `world.cyr`
  and added a Fisher-Yates bag shuffle (`rng_fill_bag`): every 7-piece window
  contains each tetromino once. The world holds an upcoming-piece queue
  (`world_peek` / `world_draw_next`) topped up a bag at a time, giving the
  multi-piece preview its lookahead. Still fully seedable + deterministic.
- **Hold piece (`world_hold`).** Stash the active piece and bring out the
  held one (or a fresh queue piece), once per drop; a placed piece re-arms
  hold. Bound to `c`.
- **Ghost piece.** `world_ghost_y` projects the hard-drop landing row;
  `render.cyr` draws the landing shadow dim behind the active piece.
- **Hard drop (`world_hard_drop`).** Slams the piece to its landing row,
  scores two points per cell, and locks immediately. Bound to space.
- **Multi-piece NEXT queue + HOLD slot in the HUD.** `hud.cyr` reads the
  upcoming queue (`HUD_PREVIEW_COUNT` pieces) and renders the held piece.
- **Scoring extensions (`score.cyr` + `world_lock_sequence`).** T-spin-aware
  base scoring (`score_base`: mini 100/200/400, proper 400/800/1200/1600),
  back-to-back +50% on consecutive difficult clears (`is_difficult`), and
  combo bonus (`combo_bonus`, 50 × combo × level). T-spin detection is the
  documented 3-corner rule (`world_tspin_kind` + `board_solid`), mini vs
  proper by the front-corner rule with the outermost SRS kick promoting.

### Changed
- **Controls remapped for the new actions.** Space is now hard drop (was soft
  drop); soft drop stays on `s` / down-arrow; `c` holds. Decoder is
  unit-tested.
- **`world.cyr` struct grew** for the bag queue, hold slot, and
  rotation/back-to-back/combo/T-spin tracking; the deterministic mutators
  remain timing-free. The single `WO_NEXT` slot was replaced by the queue.
- **Toolchain pin bumped 6.0.1 → 6.2.2** (`cyrius.cyml [package].cyrius`),
  clearing the long-standing pin↔wrapper drift warning.
- **CI/release workflows repaired** to install the toolchain via the upstream
  `install.sh` (reads the pin from `cyrius.cyml`, lays out the versioned
  `~/.cyrius/versions/<v>/` tree that `cyrius deps` resolves from) instead of
  a manual flat tarball copy; lint is now a hard gate (any `warn` fails CI).
- **`lib/` is no longer committed** — the resolved stdlib snapshot is
  gitignored and materialised by `cyrius deps` from the version-pinned
  toolchain, so the repo can't carry a stale copy (removed 81 vendored files;
  the `cwd ./lib/ shadows version-pinned …` note no longer fires).

## [0.3.0] - 2026-06-03

**M2 — progression & feel.** Turns the playable core into a game with a
difficulty curve and modern input feel, now that the interactive loop is
confirmed running live (0.2.2). The simulation stays a pure, deterministic
integer core — all new timing logic lives in headless-testable modules and
is proven by unit tests (160 assertions, up from 121). The render/feel
items (HUD layout, next preview, game-over screen, line-clear flash) build
and pixel-test headless but still want a console playtest for *feel*.

### Added
- **`gravity.cyr` — per-level gravity curve.** `gravity_frames(level)`
  implements the documented classic NES-era frames-per-cell table (48
  frames/cell at level 0 tightening to 1 at level 29+), the public
  reference curve cited per [ADR 0001](docs/adr/0001-original-puzzle-from-observation.md).
  Plus soft-drop cadence + lock-delay constants.
- **Frame-tick model + lock delay (`world.cyr`).** New `world_tick(wd, soft)`
  is the loop's heartbeat: gravity falls on its own per-level schedule and a
  grounded piece commits only after a `LOCK_DELAY_FRAMES` grace window, with
  bounded move/rotate lock-delay resets (`world_grounded`, `world_lock_reset`).
  Soft drop tightens the fall cadence and scores per cell. The deterministic
  `world_gravity` step (1 cell/frame) is retained for the headless smoke.
- **`das.cyr` — delayed auto-shift.** Pure horizontal-movement state machine:
  tap = one cell, hold = initial delay then auto-repeat. Documents the
  raw-tty no-key-up constraint.
- **`hud.cyr` — HUD + next-piece preview.** Adapts the proven cyrius-bb 3x5
  bitmap font (digits + A-Z); side panel renders SCORE / LEVEL / LINES and a
  NEXT-piece preview. The offscreen surface widens to well + 90px HUD panel.
- **Game-over screen + line-clear flash** in the interactive loop: an
  explicit GAME OVER overlay (HUD stays visible, waits for a key) and a
  brief white well-border strobe on a clear.

### Changed
- **`main.cyr` interactive loop rewritten to the tick model.** Horizontal
  input routes through DAS; soft drop drives `world_tick`'s `soft` flag;
  gravity + lock delay are owned by the world, not a loop-side counter. The
  fixed `GRAVITY_FRAMES` constant is gone (replaced by the per-level curve).

### Fixed
- **Cyrius `literal * ENUM + literal` mis-parse, defensively parenthesised.**
  `10 * CELL + 90` compiled to `CELL + 90` (the multiply dropped), which
  would have sized the render surface to 102px instead of 210; now written
  `(10 * CELL) + 90` (and the same guard in `hud_panel_x`). This is the
  concrete case behind CLAUDE.md's "mixed expressions require explicit
  parens".

## [0.2.2] - 2026-06-03

Interactive-loop input fix. The raw-tty setup wrote the `c_cc[VMIN]` /
`c_cc[VTIME]` control bytes one slot too low, so `VMIN` (byte 23) was never
zeroed and kept its inherited canonical-mode value (1). With `VMIN=1`,
`read()` on stdin blocked until a key arrived, freezing the whole frame
loop — gravity and rendering only advanced on a keypress, making the
falling piece appear locked to player input. The pure key decoder and the
121 headless assertions never exercised the live tty path, so this only
surfaced on a real console playtest. First confirmed working live with the
fix in place.

### Fixed
- **`input.cyr` — `c_cc` offset off-by-one.** `input_init` now writes
  `c_cc[VMIN]` at byte 23 and `c_cc[VTIME]` at byte 22 (the array starts at
  byte 17, after the four 4-byte flag words + the 1-byte `c_line`; `VTIME`
  is index 5, `VMIN` index 6). This matches the proven cyrius-bb /
  cyrius-doom termios setup, whose comment documents this exact trap.
  `read()` is now genuinely non-blocking (`VMIN=0`/`VTIME=0`), so the loop
  free-runs at ~60 fps and gravity falls on its own while input is polled
  non-destructively.

## [0.2.1] - 2026-06-01

Framebuffer geometry fix. The live `/dev/fb0` present path assumed the
console was exactly the surface size with a packed `width*4` pitch and
blitted a tightly-packed block at offset 0. On any real panel (e.g.
1920×1080) this tiled the surface horizontally and collapsed it into the
top band of the screen. The offscreen surface + PPM path is
self-describing, so the headless smoke never caught it. `present.cyr` now
probes the real geometry and integer-scales + centres the blit — the same
fix already shipped in cyrius-bb (and cyrius-doom v0.27.4).

### Fixed
- **`present.cyr` — real panel geometry.** `fb_present_open` now issues
  `FBIOGET_VSCREENINFO` (0x4600) + `FBIOGET_FSCREENINFO` (0x4602) ioctls
  to read `xres` / `yres` / `line_length`, with defensive fallbacks if the
  driver reports nothing. Computes the largest integer scale (capped at
  4×) that fits both axes and the centring letterbox offsets once at open,
  and blacks the whole screen once.
- **`fb_present_blit` — correct stride-aware blit.** Builds each scaled
  BGRX row in a scratch buffer and `lseek`s to the true `(oy + sy*s)*stride
  + ox*4` offset per row instead of streaming a packed block from offset 0,
  so the frame lands centred at the right pitch instead of tiling.

## [0.2.0] - 2026-05-26

### Added
- **M1 playable core** (classic MVP, self-rolled on bare stdlib per ADR 0003) — the deterministic integer simulation plus a self-rolled renderer / input / loop:
  - `src/piece.cyr` — the seven tetrominoes in four rotation states each, packed SRS cell geometry (`piece_word` / `cell_x` / `cell_y`); pure, no allocation.
  - `src/board.cyr` — 10×20 grid: collision, lock-down, full-row detection, and bottom-up line-clear compaction.
  - `src/world.cyr` — game state + step: seedable LCG piece RNG, spawn/top-out, move, naïve rotate (no wall kicks yet), gravity, soft drop, lock→clear→score→spawn.
  - `src/score.cyr` — guideline base scoring (Single/Double/Triple/Tetris = 100/300/500/800 × level) + level-per-10-lines.
  - `src/framebuf.cyr`, `src/render.cyr` — offscreen RGB surface + flat-cell renderer (placeholder per-type palette per ADR 0002) + PPM dump.
  - `src/input.cyr`, `src/tick.cyr`, `src/present.cyr` — raw-tty input (pure `poly_key_action` decoder + arrow keys), ~60 fps pacing, best-effort `/dev/fb0` blit.
  - `src/main.cyr` — interactive loop and a deterministic headless `<frames> [seed]` smoke mode (dumps a PPM, prints score/lines/level/state/cells).
  - `tests/cyrius-polyomino.tcyr` — **121 headless assertions** across piece, board, rng, world (move/rotate/gravity/clear/top-out), score, render, and input; deterministic. fmt + lint + vet clean. DCE binary 85,912 B.
- Project identity set: an original falling-block puzzle in Cyrius — a generic, trademark-clean homage to the 1984-era genre (not branded as the trademarked title).
- ADR 0001 (original puzzle, mechanics from observation), ADR 0002 (original assets only), ADR 0003 (self-rolled primitives; defer kiran / impetus / mabda) — mirroring the cyrius-bb / cyrius-doom pattern.
- Roadmap through v1.0: M0 scaffold → M1–M2 classic playable core → M3 modern guideline layer (SRS, 7-bag, hold, ghost, hard drop) → M4 audio → M5 high-scores → M6 polish.
- **Benchmarks**: `benches/polyomino.bcyr` (piece_word 22ns, board_collides 48ns, board_clear_lines 173ns, render_world 381µs/frame) + `scripts/bench-history.sh` CSV trail; baseline captured in `bench-history.csv`.
- **P(-1) security audit**: `docs/audit/2026-05-26-audit.md` — full 8-point checklist; 0 CRITICAL/HIGH/MEDIUM, 2 LOW (both fixed below).
- Root governance files: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md` (the first-party required-root-files set).

### Changed
- `cyrius.cyml`: filled in `description`, switched `version` to `${file:VERSION}`, added `repository`, fixed `output` to `build/cyrius-polyomino`, removed a stray `---` line, and documented the earmarked external deps (vani / sankoch / sigil) as commented-out blocks.
- `CLAUDE.md`, `README.md`, `docs/development/state.md`: filled in from `cyrius init` placeholders to reflect the project identity, self-rolled approach, Cyrius conventions, and homage/assets constraints.

### Security
- **LOW-1** (audit 2026-05-26): `fb_get` now bounds-checks `x`/`y` like `fb_set` — out-of-range reads return 0 instead of touching memory.
- **LOW-2** (audit 2026-05-26): `input_init` now checks the `ioctl(TCGETS)` return and leaves the terminal in cooked mode (returns -1) when stdin is not a tty, rather than configuring raw mode from uninitialised termios.

## [0.1.0]

### Added
- Initial project scaffold
