# cyrius-polyomino — Roadmap

> Milestone plan through v1.0. State lives in [`state.md`](state.md); this
> file is the sequencing — what ships, in what order, against what
> dependency gates.

## Guiding objective

**Ship a complete, deterministic falling-block puzzle in Cyrius.** A
*polyomino* is a shape made of unit cells joined edge-to-edge; the four-cell
case — the **tetromino** — is the genre's building block (the seven one-sided
tetrominoes: I, O, T, S, Z, J, L). cyrius-polyomino is an original homage to
the falling-block puzzle genre (1984-era), reimplemented from observation of
its documented public mechanics. See [ADR 0001](../adr/0001-original-puzzle-from-observation.md).

Same retro-game-in-Cyrius lineage as [cyrius-doom](https://github.com/MacCracken/cyrius-doom)
(engine novelty) and [cyrius-bb](https://github.com/MacCracken/cyrius-bb)
(accessible-scope brick-breaker). Like both, the simulation core is **pure
integer grid logic** — deterministic, fully unit-testable headless, renderer
and input self-rolled on bare stdlib ([ADR 0003](../adr/0003-self-rolled-primitives.md)).

**Shape of the plan**: an MVP-first ramp. M1–M2 ship a *classic* playable game
(grid, seven tetrominoes, gravity, line clears, scoring, level speed-curve).
M3 then layers the *modern guideline* features (SRS rotation + wall kicks,
7-bag, hold, ghost, hard drop) on top of a core proven to work. Audio, save,
and polish follow the same milestone cadence cyrius-bb uses.

## v1.0 criteria

- [ ] All milestones M1–M6 complete; classic core + modern guideline layer both shipped
- [ ] Public-facing behavior frozen — board geometry, scoring table, and rotation system documented and tested
- [ ] Deterministic headless simulation: a fixed input + seed sequence produces a byte-identical board state and score (the speedrun/replay invariant)
- [ ] Test coverage adequate for the surface area (≥100 assertions; every module's logic exercised headless)
- [ ] Benchmarks captured in `docs/benchmarks.md` (board step, line-clear scan, collision)
- [ ] Interactive console playthrough verified on a real Linux `/dev/fb0` console (top-out, level-up, line-clear feel)
- [ ] CHANGELOG complete from v0.1.0 onward
- [ ] Security audit pass (`docs/audit/YYYY-MM-DD-audit.md`)
- [ ] Original assets only — no trademarked names, sprites, palettes, or the canonical theme tune ([ADR 0002](../adr/0002-original-assets-only.md))

## Milestones

### M0 — Scaffold (v0.1.0) — ✅ shipped 2026-05-26

- `cyrius init` scaffold landed; binary-vs-library decision (binary — game)
- Project identity set: original polyomino puzzle, generic homage (not Tetris-branded)
- ADR 0001 (puzzle-from-observation), ADR 0002 (original-assets-only), ADR 0003 (self-rolled primitives) seeded
- Doc-tree per [first-party-documentation.md](https://github.com/MacCracken/agnosticos/blob/main/docs/development/first-party/first-party-documentation.md)
- Toolchain pinned `cyrius = "6.0.1"` (matches cyrius-bb / cyrius-doom)

### M1 — Playable core / "it's a game" (v0.2.0) — ✅ shipped 2026-05-26

*The classic MVP. The point where pieces fall, lock, and lines clear.*

Shipped: the deterministic integer core + self-rolled I/O, 121 headless
assertions, P(-1) hardening pass (benchmarks + security audit, 2 LOW fixed).
fmt/lint/vet clean; DCE binary 85,912 B. Detail in [`CHANGELOG.md`](../../CHANGELOG.md)
`[0.2.0]`.

**Carried forward** (not blocking): console playtest of the interactive loop +
`/dev/fb0` present on a real Linux console — build/lint + headless-smoke-verified
only so far (no console/framebuffer in dev/CI).

Self-rolled on bare stdlib ([ADR 0003](../adr/0003-self-rolled-primitives.md)),
following the cyrius-doom / cyrius-bb pattern:

- `src/board.cyr` — the 10×20 visible playfield (+ hidden spawn/vanish rows above), cell occupancy grid, lock-down, full-row detection + clear + compaction
- `src/piece.cyr` — the seven tetrominoes (I, O, T, S, Z, J, L) as cell offsets, four rotation states each, naïve rotation (no wall kicks yet — that's M3)
- `src/rng.cyr` — piece sequence generator; **seedable** (deterministic for tests/replays). Uniform random to start; 7-bag arrives in M3
- `src/world.cyr` — game state + `world_step()`: gravity-on-tick, move L/R, soft drop, rotate, spawn-next, lock, top-out detection
- `src/score.cyr` — line counter + classic line-clear scoring (single/double/triple/quad), level counter
- `src/framebuf.cyr` — offscreen RGB surface + clipped fill + PPM dump (self-rolled; cyrius-doom/bb pattern)
- `src/render.cyr` — draw locked cells + active piece as flat blocks
- `src/input.cyr` — raw-tty: left / right / soft-drop / rotate / quit (+ pure key→action decoder for headless tests)
- `src/tick.cyr` — ~60 fps frame pacing + gravity interval
- `src/present.cyr` — best-effort `/dev/fb0` blit (console-only)
- `src/main.cyr` — real-time loop **and** a headless `cyrius-polyomino <frames>` smoke mode (step N ticks from a seed, dump a PPM, print score + lines)
- Headless deterministic unit tests in `tests/cyrius-polyomino.tcyr` (target ≥100 assertions across board / piece / rng / world / score / render / input-decode)

**Acceptance**: a piece spawns at the top, falls under gravity, moves and
rotates within the well, locks when it lands, completed rows clear and shift
everything above down, score accrues, and a stack that reaches the top ends the
game. One deterministic headless run reproduces a known board + score; the
interactive loop is playable on a Linux console.

### M2 — Progression & feel (v0.3.0) — ✅ shipped 2026-06-03

*Turn the loop into a game with depth — classic difficulty curve.*

Shipped (160 headless assertions; detail in [`CHANGELOG.md`](../../CHANGELOG.md) `[0.3.0]`):

- ✅ Per-level **gravity curve** — `gravity.cyr`, the documented NES frames-per-cell table (48→1), cited per [ADR 0001](../adr/0001-original-puzzle-from-observation.md)
- ✅ **Level advance** every 10 lines (carried from M1's `level_for_lines`); lines + level + score displayed in the HUD
- ✅ **DAS** (`das.cyr`, pure state machine) + soft-drop cadence via the tick's `soft` flag
- ✅ **Next-piece preview** (single piece) in the HUD panel
- ✅ **Line-clear flash** + an explicit **game-over screen** (waits for a key, not just loop-exit)
- ✅ Basic **lock delay** — `world_tick` grace window with bounded move/rotate resets
- ✅ HUD: score, level, lines, next piece (3x5 bitmap font, cyrius-bb pattern)

**Carried forward** (not blocking): M2 console playtest to tune *feel*
(the timing constants), the soft-drop tty-autorepeat smoothness, and the
richer per-row line-clear animation (needs the lock/detect/clear split,
deferred to M3 polish).

**Acceptance**: a player can start at level 0, watch the speed ramp with each
level, clear lines for classic scoring, and top out to a game-over screen with
their final score. Speed curve traces to a documented public source.

### M3 — Modern guideline layer (v0.4.0) — ✅ shipped 2026-06-14

*Layer the modern "feel" features on the proven classic core.*

Shipped (235 headless assertions; detail in [`CHANGELOG.md`](../../CHANGELOG.md) `[0.4.0]`):

- ✅ **SRS** (Super Rotation System) — wall-kick offset tables (`srs.cyr`), the modern rotation standard; `world_rotate` tries the five kicks in order. Reference pinned in [`docs/standards/srs-rotation.md`](../standards/srs-rotation.md), cited per [ADR 0001](../adr/0001-original-puzzle-from-observation.md)
- ✅ **7-bag randomizer** — `rng.cyr` Fisher-Yates bag feeding an upcoming-piece queue in the world; uniform RNG retired; still seedable
- ✅ **Hold piece** — `world_hold`, one swap per drop, re-armed on lock
- ✅ **Ghost piece** — `world_ghost_y` projection rendered dim behind the active piece
- ✅ **Hard drop** — `world_hard_drop`, instant drop + lock + two-per-cell bonus
- ✅ **Scoring extensions** — back-to-back, combo, and **T-spin** (3-corner rule, mini/proper) in `score.cyr` + `world_lock_sequence`
- ✅ Multi-piece next-queue preview + HOLD slot in the HUD

**Acceptance met**: rotation + wall-kick behavior matches the documented
guideline (unit-tested kick tables, wall + floor kicks); hold / ghost /
hard-drop / 7-bag all functional; back-to-back + combo + T-spin scoring
correct against hand-calculated expectations. The deterministic-replay
invariant still holds with the 7-bag seeded.

**Carried forward** (not blocking): M2+M3 console playtest for *feel*; the
richer per-row line-clear animation (needs splitting the lock/detect/clear
steps in `world.cyr`).

### M4 — Audio pass (v0.5.0)

- `src/audio.cyr` — sound effects: move/rotate blip, soft-lock thud, line-clear chime, **quad-clear fanfare**, level-up cue, top-out sting
- Era-spirit synthesis (square / simple FM), no sampled audio. Routed through **vani** (the Cyrius audio device surface cyrius-doom already consumes) — *available*, not a pending-port gate
- Optional slot-loaded music from `~/.cyrius-polyomino/music/` (user-provided `.ogg`); **silent by default if absent**. The canonical falling-block theme is *not* shipped (it carries trademark/licensing baggage even where the underlying folk tune is public-domain) — any bundled music is original composition ([ADR 0002](../adr/0002-original-assets-only.md))
- Mute toggle

**Acceptance**: audio reinforces the gameplay rhythm without demanding
attention; playtest confirms the line-clear cues land on the clear, not after.

### M5 — High-score persistence (v0.6.0)

- `src/save.cyr` — high-score table at `~/.cyrius-polyomino/scores.cyb` (custom extension), **sankoch**-compressed + **sigil**-integrity-hashed (don't self-roll crypto/compression — [ADR 0003](../adr/0003-self-rolled-primitives.md) retains these as real deps)
- Top-10 persistent scores with player initials
- Score-entry UI on game-over when the score qualifies
- Tamper detection — sigil hash mismatch ⇒ corrupted save; refuse to load, don't crash

**Acceptance**: scores persist across sessions; hand-editing the file
invalidates it; a legitimate game produces a score matching a hand-calculated
expectation.

### M6 — Polish (v0.9.0)

- Menu screen (title / play / high scores / quit) + **pause**
- Screen-size / windowed-mode handling on the framebuffer
- Final art + palette pass — placeholder solid-color cells replaced with the final original block art ([ADR 0002](../adr/0002-original-assets-only.md))
- Accessibility pass — keyboard-only play (already true), color-blind-friendly piece colors, rebindable keys, configurable DAS

### v1.0 — Ship

**Scope at v1.0**:
- M1–M6 complete: classic core + modern guideline layer, audio, save, polish
- Playtest against the documented genre mechanics for *feel* (the unit tests prove determinism; playtest proves it's fun)
- CI matrix green on all Cyrius-supported platforms; security audit pass; CHANGELOG complete; benchmarks captured

**Target date**: _not yet pinned._ Candidate narrative anchor — the genre's
origin (Alexey Pajitnov, June 1984). Unlike cyrius-bb (deliberately one-week
scope), the M3 modern-guideline layer makes this a meaningfully larger build;
pin the date once M1–M2 land and the per-milestone velocity is known, rather
than committing speculatively now. Sibling context: cyrius-bb targets
2026-06-13 and the summer-2026 arc's Beat 1 solstice demo is 2026-06-21.

## Out of scope (for v1.0)

Kept here so future contributors don't quietly grow v1.0:

- **Networked / versus multiplayer** (garbage-line attack) — a separate project
- **3D / perspective rendering** — this is a flat 2D grid; orthogonal only
- **Mobile / touch input** — keyboard-only for v1.0
- **The canonical branded theme tune and any trademarked naming/art** — original assets only ([ADR 0002](../adr/0002-original-assets-only.md))
- **The heavy game stack** (kiran ECS, impetus physics, mabda GPU) — deferred per [ADR 0003](../adr/0003-self-rolled-primitives.md); a grid puzzle doesn't need them

## Post-v1.0 (not scheduled)

- **Game modes** — Sprint (40-line time attack), Ultra (2-minute score attack), Marathon — fall out naturally from the deterministic core
- **Replays** — record the seed + input stream; the deterministic sim replays bit-identically (speedrun-friendly)
- **Level / layout editor** — needs file-format versioning discipline first
- **Gamepad support** — better than keyboard for the genre
- **Community palettes / themes** — CC-BY, once the asset pipeline is stable

## Dependency gates

| Milestone | Deps | Status |
|-----------|------|--------|
| M1–M3 | bare Cyrius stdlib (self-rolled core) | ✅ available |
| M4 | `vani` (audio device I/O) | ✅ available (cyrius-doom pins 0.9.4) |
| M5 | `sankoch` (compression), `sigil` (integrity hash) | ✅ available |

No part of the critical path is blocked on a pending Rust→Cyrius port — the
self-rolled decision ([ADR 0003](../adr/0003-self-rolled-primitives.md)) keeps
M1–M3 on bare stdlib, and the audio/save deps are already Cyrius-native.

See [ADR 0001](../adr/0001-original-puzzle-from-observation.md) for the
homage-from-observation thesis, [ADR 0002](../adr/0002-original-assets-only.md)
for the assets policy, [ADR 0003](../adr/0003-self-rolled-primitives.md) for the
self-rolled-primitives decision, and [`state.md`](state.md) for live progress.
