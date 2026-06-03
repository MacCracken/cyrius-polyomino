# cyrius-polyomino — Current State

> Refreshed every release. CLAUDE.md is preferences/process/procedures
> (durable); this file is **state** (volatile).

## Version

**0.3.0 — M2 progression & feel** (cut 2026-06-03). Adds the classic
difficulty ramp + modern input feel on the proven core: a per-level gravity
curve (`gravity.cyr`, documented NES frames-per-cell table), a frame-tick
model with lock delay (`world_tick` / `world_grounded` in `world.cyr`),
delayed auto-shift (`das.cyr`), a HUD with score/level/lines + next-piece
preview (`hud.cyr`, cyrius-bb bitmap font), and an explicit game-over screen
+ line-clear flash in the loop. All new timing logic is deterministic and
headless-tested (160 assertions). Caught + parenthesised a Cyrius
`literal * ENUM + literal` mis-parse along the way. (Prior: 0.2.2 —
interactive-loop input fix, 2026-06-03: the `c_cc[VMIN]`/`c_cc[VTIME]`
termios bytes were one slot too low, so `read()` blocked until a keypress
and the piece appeared locked to player input; fixed to bytes 23/22, first
confirmed working live. 0.2.1 — framebuffer geometry fix, 2026-06-01:
`present.cyr` probes real `/dev/fb0` geometry and integer-scales + centres
the blit. 0.2.0 — M1 playable core complete, 2026-05-26. 0.1.0 — scaffold +
first-party alignment, 2026-05-26.) The version files are bumped to 0.3.0;
the git tag is the user's to create.

- **DCE binary**: 100,072 B (x86_64, static, stripped) — +12,496 B vs 0.2.1 (M2 modules: gravity curve, tick/lock-delay, DAS, HUD bitmap font + next preview).
- **Tests**: 160 assertions, 0 failed (+39 for gravity / world tick / DAS / HUD). fmt + lint + vet clean.
- **Benchmarks**: piece_word 22ns · board_collides 48ns · board_clear_lines 173ns · render_world 381µs/frame (`bench-history.csv`).
- **Security**: P(-1) audit clean — 0 CRIT/HIGH/MED, 2 LOW fixed ([2026-05-26 audit](../audit/2026-05-26-audit.md)).
- **Deps**: bare stdlib — zero external deps (vani / sankoch / sigil re-wire at M4/M5).
- **Caveat**: the interactive loop + `/dev/fb0` present are confirmed
  running live on a real console (0.2.2). The M2 *feel* layer — gravity-curve
  speed ramp, lock-delay grace, DAS auto-shift, soft-drop cadence — and the
  M2 *render* layer — HUD panel, next preview, game-over screen, line-clear
  flash — build + pixel-test headless but want a console playtest to tune.
  Known tty limitation: a raw terminal has no key-release event, so DAS and
  soft-drop "hold" detection ride the kernel autorepeat stream (documented
  in `das.cyr`). In dev/CI (no console/framebuffer) the simulation is proven
  by the 160 deterministic assertions + the seedable `<frames>` smoke
  (verified to vary by seed; renders a valid 210×240 PPM).

## Toolchain

- **Cyrius pin**: `6.0.1` (in `cyrius.cyml [package].cyrius`) — matches cyrius-bb / cyrius-doom.

## Source

M1 + M2 complete on the dev tip — the deterministic integer core + self-rolled
I/O + the progression/feel layer, per [ADR 0003](../adr/0003-self-rolled-primitives.md):

- `src/piece.cyr` — seven tetrominoes × four rotations, packed SRS cell geometry (pure)
- `src/board.cyr` — 10×20 grid: collision, lock, full-row detect, line-clear compaction
- `src/gravity.cyr` — per-level gravity curve (documented NES frames-per-cell table) + soft-drop / lock-delay constants (M2)
- `src/world.cyr` — state + step: seedable LCG RNG, spawn/top-out, move, naïve rotate, gravity, soft drop, lock→clear→score→spawn; **plus the real-time `world_tick` (gravity timer + lock delay + soft accel) and `world_grounded`** (M2)
- `src/score.cyr` — guideline base scoring (100/300/500/800 × level) + level-per-10-lines
- `src/das.cyr` — delayed auto-shift state machine for horizontal movement (M2, pure)
- `src/framebuf.cyr` / `src/render.cyr` — offscreen surface + flat-cell renderer (placeholder palette, ADR 0002) + PPM dump
- `src/hud.cyr` — 3x5 bitmap font (cyrius-bb pattern) + side-panel HUD (score/level/lines) + next-piece preview (M2)
- `src/input.cyr` / `src/tick.cyr` / `src/present.cyr` — raw-tty input + decoder, ~60 fps pacing, geometry-probed (`FBIOGET_{V,F}SCREENINFO`) integer-scaled + centred `/dev/fb0` blit
- `src/main.cyr` — interactive loop (tick model + DAS + HUD + game-over screen + line-clear flash) + deterministic headless `<frames> [seed]` smoke

Planned: `src/rng.cyr` split + 7-bag (M3), SRS wall kicks (M3),
`src/audio.cyr` (M4, via vani), `src/save.cyr` (M5, sankoch + sigil). (RNG
currently lives inline in `world.cyr`.)

## Tests

- `tests/cyrius-polyomino.tcyr` — **160 assertions, 0 failed**: piece (packing/geometry), board (collision/lock/clear), rng (determinism/range), world (move/rotate/gravity/clear/top-out), **world tick (gravity timing / lock delay / lock-reset / soft drop), gravity curve, DAS**, score, render (pixel checks), **HUD (font / number / preview / panel layout)**, input (key decode). Deterministic + headless.
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

1. **M2 console playtest** — verify the speed ramp, lock-delay grace, DAS
   auto-shift, soft-drop cadence, HUD/next-preview, game-over screen, and
   line-clear flash *feel* right on a real Linux console. Tune the
   `gravity.cyr` / `das.cyr` constants (DAS_DELAY/RATE, LOCK_DELAY_FRAMES,
   SOFT_DROP_FRAMES) and revisit the soft-drop tty-autorepeat smoothness.
2. **M3 — modern guideline layer** (v0.4.0): SRS rotation + wall kicks,
   7-bag randomiser (split `rng.cyr`), hold, ghost, hard drop, multi-preview;
   plus the richer per-row line-clear animation (needs splitting the
   lock/detect/clear steps in `world.cyr`).

Resolved at the 0.2.0 cut: benchmarks + CSV trail, P(-1) security audit (2 LOW
fixed), and the `CONTRIBUTING` / `CODE_OF_CONDUCT` / `SECURITY` root files
(`cyrius init` 6.0.1 does not emit these three — sourced from the cyrius-bb
template lineage and adapted).
