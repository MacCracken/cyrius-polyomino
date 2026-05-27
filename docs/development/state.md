# cyrius-polyomino — Current State

> Refreshed every release. CLAUDE.md is preferences/process/procedures
> (durable); this file is **state** (volatile).

## Version

**0.1.0** — scaffolded 2026-05-26 via `cyrius init`, then aligned to
first-party standards (identity set as an original falling-block puzzle / generic
homage; ADRs 0001–0003 seeded; roadmap written). No releases yet.

## Toolchain

- **Cyrius pin**: `6.0.1` (in `cyrius.cyml [package].cyrius`) — matches cyrius-bb / cyrius-doom.

## Source

Initial scaffold only — `src/main.cyr` is the `cyrius init` stub. The playable
core (M1) is the next work.

Planned modules (M1, self-rolled per [ADR 0003](../adr/0003-self-rolled-primitives.md)):

- `src/board.cyr` — 10×20 grid, occupancy, lock-down, full-row detect + clear + compaction
- `src/piece.cyr` — seven tetrominoes, four rotation states each
- `src/rng.cyr` — seedable piece sequence (uniform first; 7-bag in M3)
- `src/world.cyr` — game state + `world_step()` (gravity, move, rotate, lock, top-out)
- `src/score.cyr` — line-clear scoring + level + lines counters
- `src/framebuf.cyr` / `src/render.cyr` — offscreen surface + cell render (self-rolled)
- `src/input.cyr` / `src/tick.cyr` / `src/present.cyr` — raw-tty input, frame pacing, `/dev/fb0` blit
- `src/main.cyr` — real-time loop + headless `<frames>` smoke mode

Planned later: `src/audio.cyr` (M4, via vani), `src/save.cyr` (M5, sankoch + sigil).

## Tests

- `tests/cyrius-polyomino.tcyr` — primary suite (smoke + math; **2 assertions, 0 failed** on `cyrius test`)
- `tests/cyrius-polyomino.bcyr` — benchmark stub (no-op)
- `tests/cyrius-polyomino.fcyr` — fuzz stub
- Target for M1: ≥100 deterministic headless assertions across the simulation modules.

## Dependencies

Direct (declared in `cyrius.cyml`): bare stdlib — `string, fmt, alloc, io, vec,
str, syscalls, assert`. Self-rolled core; zero external deps ([ADR 0003](../adr/0003-self-rolled-primitives.md)).

Earmarked (commented out until their milestone): `vani` (M4 audio),
`sankoch` + `sigil` (M5 high-score save).

## Consumers

_None — this is a leaf binary (game)._

## Next

See [`roadmap.md`](roadmap.md). Immediate sequence:

1. **M1 — playable core** (v0.2.0): board / piece / rng / world / score +
   self-rolled framebuf / render / input / tick / present, with a headless
   `<frames>` smoke mode and ≥100 deterministic assertions. Acceptance: pieces
   spawn, fall, move, rotate, lock; full rows clear; score accrues; top-out
   ends the game.
2. **P(-1) hardening** before the v0.2.0 cut — fmt / lint / vet clean, baseline
   benchmarks, first security-audit pass (`docs/audit/`).
3. **Scaffold gaps** (carry-in): `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
   `SECURITY.md` are absent — regenerate via the scaffold tool rather than
   hand-rolling (first-party standards: don't hand-roll the seven root files).
