# cyrius-polyomino — Current State

> Refreshed every release. CLAUDE.md is preferences/process/procedures
> (durable); this file is **state** (volatile).

## Version

**0.2.1 — framebuffer geometry fix** (cut 2026-06-01). `present.cyr` now
probes real `/dev/fb0` `xres`/`yres`/`line_length` via `FBIOGET_{V,F}SCREENINFO`
and integer-scales + centres the blit, replacing the surface-sized packed-block
assumption that tiled the frame into the top band of a real panel (the
self-describing PPM/headless path masked it). Same fix as cyrius-bb / cyrius-doom
v0.27.4. (Prior: 0.2.0 — M1 playable core complete, 2026-05-26: 10×20 well,
seven tetrominoes, gravity, line clears + scoring, self-rolled renderer / input /
loop, plus the P(-1) hardening pass. 0.1.0 — scaffold + first-party alignment,
2026-05-26.) The version files are bumped to 0.2.1; the git tag is the user's to
create.

- **DCE binary**: 87,576 B (x86_64, static, stripped) — +1,664 B vs 0.2.0 (fb geometry probe + scaled blit).
- **Tests**: 121 assertions, 0 failed. fmt + lint + vet clean.
- **Benchmarks**: piece_word 22ns · board_collides 48ns · board_clear_lines 173ns · render_world 381µs/frame (`bench-history.csv`).
- **Security**: P(-1) audit clean — 0 CRIT/HIGH/MED, 2 LOW fixed ([2026-05-26 audit](../audit/2026-05-26-audit.md)).
- **Deps**: bare stdlib — zero external deps (vani / sankoch / sigil re-wire at M4/M5).
- **Caveat**: the interactive loop + `/dev/fb0` present are build/lint-verified
  + headless-smoke-verified only (no console/framebuffer in dev/CI); the
  simulation is proven by the 121 deterministic assertions + the seedable
  `<frames>` smoke (verified to vary by seed; renders a valid PPM).

## Toolchain

- **Cyrius pin**: `6.0.1` (in `cyrius.cyml [package].cyrius`) — matches cyrius-bb / cyrius-doom.

## Source

M1 complete on the dev tip — the deterministic integer core + self-rolled I/O,
per [ADR 0003](../adr/0003-self-rolled-primitives.md):

- `src/piece.cyr` — seven tetrominoes × four rotations, packed SRS cell geometry (pure)
- `src/board.cyr` — 10×20 grid: collision, lock, full-row detect, line-clear compaction
- `src/world.cyr` — state + step: seedable LCG RNG, spawn/top-out, move, naïve rotate, gravity, soft drop, lock→clear→score→spawn
- `src/score.cyr` — guideline base scoring (100/300/500/800 × level) + level-per-10-lines
- `src/framebuf.cyr` / `src/render.cyr` — offscreen surface + flat-cell renderer (placeholder palette, ADR 0002) + PPM dump
- `src/input.cyr` / `src/tick.cyr` / `src/present.cyr` — raw-tty input + decoder, ~60 fps pacing, geometry-probed (`FBIOGET_{V,F}SCREENINFO`) integer-scaled + centred `/dev/fb0` blit
- `src/main.cyr` — interactive loop + deterministic headless `<frames> [seed]` smoke

Planned: `src/rng.cyr` split + 7-bag (M3), `src/audio.cyr` (M4, via vani),
`src/save.cyr` (M5, sankoch + sigil). (RNG currently lives inline in `world.cyr`.)

## Tests

- `tests/cyrius-polyomino.tcyr` — **121 assertions, 0 failed**: piece (packing/geometry), board (collision/lock/clear), rng (determinism/range), world (move/rotate/gravity/clear/top-out), score, render (pixel checks), input (key decode). Deterministic + headless.
- `tests/cyrius-polyomino.bcyr` — benchmark stub (no-op; real benches at the P(-1) pass)
- `tests/cyrius-polyomino.fcyr` — fuzz stub
- Playtest gate: the interactive loop + `/dev/fb0` present need a real Linux console (build/lint + headless-smoke-verified only so far).

## Dependencies

Direct (declared in `cyrius.cyml`): bare stdlib — `string, alloc, fmt, io, fs,
str, vec, syscalls, args, assert`. Self-rolled core; zero external deps
([ADR 0003](../adr/0003-self-rolled-primitives.md)).

Earmarked (commented out until their milestone): `vani` (M4 audio),
`sankoch` + `sigil` (M5 high-score save).

## Consumers

_None — this is a leaf binary (game)._

## Next

See [`roadmap.md`](roadmap.md). Immediate sequence:

1. **Console playtest** (carry from M1) — verify the interactive loop +
   `/dev/fb0` present on a real Linux console; tune gravity feel before M2
   layers DAS / lock-delay on top.
2. **M2 — progression & feel** (v0.3.0): per-level gravity curve, DAS, lock
   delay, next-piece preview, line-clear animation, game-over screen, HUD.

Resolved at the 0.2.0 cut: benchmarks + CSV trail, P(-1) security audit (2 LOW
fixed), and the `CONTRIBUTING` / `CODE_OF_CONDUCT` / `SECURITY` root files
(`cyrius init` 6.0.1 does not emit these three — sourced from the cyrius-bb
template lineage and adapted).
