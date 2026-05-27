# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
