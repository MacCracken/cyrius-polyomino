# cyrius-polyomino — Current State

> Refreshed every release. CLAUDE.md is preferences/process/procedures
> (durable); this file is **state** (volatile).

## Version

**0.4.0 — M3 modern guideline layer** (cut 2026-06-14). Layers the modern
"feel" features on the proven classic core: SRS rotation + wall kicks
(`srs.cyr`, `world_rotate`), a seedable 7-bag randomiser (`rng.cyr` split out
of `world.cyr`, feeding an upcoming-piece queue), hold (`world_hold`), ghost
(`world_ghost_y` + dim render), hard drop (`world_hard_drop`), a multi-piece
NEXT queue + HOLD slot in the HUD, and the full guideline scoring extensions
— T-spin (3-corner rule, `world_tspin_kind` + `board_solid`), back-to-back,
and combo (`score.cyr`). All new logic is deterministic and headless-tested
(235 assertions, up from 160); the seed/replay invariant still holds with the
7-bag. SRS + T-spin reference pinned in
[`docs/standards/srs-rotation.md`](../standards/srs-rotation.md). (Prior:
0.3.0 — M2 progression & feel, 2026-06-03: per-level gravity curve, frame-tick
+ lock delay, DAS, HUD with next preview, game-over screen, line-clear flash;
160 assertions; caught a `literal * ENUM + literal` mis-parse. 0.2.2 —
interactive-loop input fix, 2026-06-03: `c_cc[VMIN]`/`c_cc[VTIME]` termios
bytes were one slot too low; fixed to 23/22, confirmed live. 0.2.1 —
framebuffer geometry fix, 2026-06-01. 0.2.0 — M1 playable core, 2026-05-26.
0.1.0 — scaffold, 2026-05-26.) The version files are bumped to 0.4.0; the git
tag is the user's to create.

- **DCE binary**: 112,216 B (x86_64, static, stripped) — +12,144 B vs 0.3.0 (M3 modules: SRS kicks, 7-bag/queue, hold, ghost, hard drop, multi-preview, T-spin/B2B/combo scoring).
- **Tests**: 235 assertions, 0 failed (+75 for 7-bag, SRS kicks, hard drop, hold, ghost, multi-preview HUD, and the scoring extensions). fmt + lint + vet clean.
- **Benchmarks**: piece_word 22ns · board_collides 48ns · board_clear_lines 173ns · render_world 381µs/frame (`bench-history.csv`; M3 added no hot-path benches — rotation now does up to 5 collision checks, still O(1)).
- **Security**: P(-1) audit clean — 0 CRIT/HIGH/MED, 2 LOW fixed ([2026-05-26 audit](../audit/2026-05-26-audit.md)). M3 added no external input surface (bag/SRS/scoring are pure integer logic).
- **Deps**: bare stdlib — zero external deps (vani / sankoch / sigil re-wire at M4/M5).
- **Caveat**: the interactive loop + `/dev/fb0` present are confirmed
  running live on a real console (0.2.2). The M2 *feel* layer (gravity ramp,
  lock-delay, DAS, soft drop) and the new M3 layer — SRS kick feel, hold,
  hard drop, ghost, and the T-spin/B2B/combo scoring *as it lands during
  play* — build + pixel/headless-test but want a console playtest to tune.
  Known tty limitation: a raw terminal has no key-release event, so DAS and
  soft-drop "hold" detection ride the kernel autorepeat stream (documented
  in `das.cyr`). In dev/CI (no console/framebuffer) the simulation is proven
  by the 235 deterministic assertions + the seedable `<frames>` smoke
  (verified to vary by seed; renders a valid 210×240 PPM).

## Toolchain

- **Cyrius pin**: `6.0.1` (in `cyrius.cyml [package].cyrius`) — matches cyrius-bb / cyrius-doom.

## Source

M1 + M2 + M3 complete on the dev tip — the deterministic integer core +
self-rolled I/O + progression/feel + the modern guideline layer, per
[ADR 0003](../adr/0003-self-rolled-primitives.md):

- `src/piece.cyr` — seven tetrominoes × four rotations, packed SRS cell geometry (pure)
- `src/board.cyr` — 10×20 grid: collision, lock, full-row detect, line-clear compaction; **`board_solid` corner probe for T-spin** (M3)
- `src/gravity.cyr` — per-level gravity curve (documented NES frames-per-cell table) + soft-drop / lock-delay constants (M2)
- `src/rng.cyr` — **seedable LCG + 7-bag Fisher-Yates shuffle** (M3, split out of `world.cyr`)
- `src/srs.cyr` — **Super Rotation System wall-kick tables** (JLSTZ + I, board-space; pure) (M3)
- `src/world.cyr` — state + step: spawn/top-out, move, **SRS rotate with kicks**, gravity, soft/**hard drop**, **hold**, **ghost (`world_ghost_y`)**, lock→clear→score→spawn with **T-spin/B2B/combo** (`world_tspin_kind`); real-time `world_tick` + `world_grounded`; upcoming-piece queue (`world_peek`/`world_draw_next`)
- `src/score.cyr` — base scoring (100/300/500/800 × level) + **T-spin `score_base`, `is_difficult` (B2B), `combo_bonus`** + level-per-10-lines (M3)
- `src/framebuf.cyr` / `src/render.cyr` — offscreen surface + flat-cell renderer (placeholder palette, ADR 0002) + **dim ghost piece** (M3) + PPM dump
- `src/hud.cyr` — 3x5 bitmap font (cyrius-bb pattern) + side-panel HUD (score/level/lines) + **multi-piece NEXT queue + HOLD slot** (M3)
- `src/input.cyr` / `src/tick.cyr` / `src/present.cyr` — raw-tty input + decoder (now incl. **hard drop = space, hold = c**), ~60 fps pacing, geometry-probed (`FBIOGET_{V,F}SCREENINFO`) integer-scaled + centred `/dev/fb0` blit
- `src/main.cyr` — interactive loop (tick model + DAS + hard drop + hold + HUD + game-over screen + line-clear flash) + deterministic headless `<frames> [seed]` smoke

Planned: `src/audio.cyr` (M4, via vani), `src/save.cyr` (M5, sankoch + sigil).

## Tests

- `tests/cyrius-polyomino.tcyr` — **235 assertions, 0 failed**: piece (packing/geometry), board (collision/lock/clear), rng (LCG determinism + **7-bag permutation / two-bag stream**), world (move/**SRS rotate**/gravity/clear/top-out), **SRS (offset decode / transition ids / wall + floor kick / fully-boxed fail), hard drop, hold (stash/swap/re-arm), scoring (combo / back-to-back / T-spin double + non-spin)**, world tick (gravity timing / lock delay / lock-reset / soft drop), gravity curve, DAS, score (regular + **T-spin/B2B/combo helpers**), render (pixel checks + **ghost**), HUD (font / number / preview / **multi-queue / HOLD** / panel layout), input (key decode incl. hard drop + hold). Deterministic + headless.
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

1. **M2 + M3 console playtest** — verify on a real Linux console that the
   speed ramp, lock-delay grace, DAS, and soft-drop cadence (M2) *plus* SRS
   kick feel, hold, hard drop, ghost, the multi-piece NEXT queue, and the
   T-spin/B2B/combo scoring (M3) all *feel* right. Tune the `gravity.cyr` /
   `das.cyr` constants and the soft-drop tty-autorepeat smoothness; sanity-
   check T-spin detection against hand-rotated slots.
2. **M4 — audio pass** (v0.5.0): `src/audio.cyr` via vani — move/rotate blip,
   soft-lock thud, line-clear chime, quad-clear fanfare, level-up cue,
   top-out sting; era-spirit synthesis, mute toggle.

Deferred M3 polish (not blocking): the richer per-row line-clear animation
needs splitting the lock/detect/clear steps in `world.cyr`.

Resolved at the 0.2.0 cut: benchmarks + CSV trail, P(-1) security audit (2 LOW
fixed), and the `CONTRIBUTING` / `CODE_OF_CONDUCT` / `SECURITY` root files
(`cyrius init` 6.0.1 does not emit these three — sourced from the cyrius-bb
template lineage and adapted).
