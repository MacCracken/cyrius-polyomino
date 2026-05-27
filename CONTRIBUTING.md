# Contributing to cyrius-polyomino

Thank you for your interest in contributing to **cyrius-polyomino** — an
original falling-block puzzle in Cyrius, a generic homage to the 1984-era genre.

Read [`CLAUDE.md`](CLAUDE.md) first — it is the durable process and procedures
for this repo. This file is the contributor-facing summary.

## Three hard constraints, before anything else

cyrius-polyomino is an *homage built from observation*, not a clone of a
branded product. Three ADRs govern every contribution and are non-negotiable:

- **Original puzzle, mechanics from observation** ([ADR 0001](docs/adr/0001-original-puzzle-from-observation.md)) —
  mechanics trace to documented public sources (the published guideline,
  scoring tables, gravity curves). The project is **not branded as the
  trademarked title**; use generic genre language (polyomino / tetromino /
  falling-block) only.
- **Original assets only** ([ADR 0002](docs/adr/0002-original-assets-only.md)) —
  no trademarked names, palettes, sprites, or the canonical theme tune. All
  art, audio, and music is newly created or drawn from public-domain reference.
- **Self-rolled on bare stdlib** ([ADR 0003](docs/adr/0003-self-rolled-primitives.md)) —
  no FFI, no engine/GPU/physics dep on the critical path. vani / sankoch / sigil
  are the only earmarked external deps (audio + save, M4–M5).

A PR that introduces trademarked naming/art or pulls a heavy engine dep onto
the critical path will be declined regardless of code quality.

## Prerequisites

- [Cyrius](https://github.com/MacCracken/cyrius) at the version pinned in
  [`cyrius.cyml`](cyrius.cyml) `[package].cyrius` (currently `6.0.1`) — ships
  the `cyrius` CLI and the stdlib this project depends on.
- No C toolchain, no FFI. The Cyrius stdlib carries everything — see
  [`README.md`](README.md).

Everything (deps, build, test, bench, lint, fmt) runs through the `cyrius` CLI.

## Development Workflow

1. Fork and clone the repository
2. Resolve deps: `cyrius deps`
3. Make changes under `src/`, `tests/`, `benches/`, or `docs/`
4. Build: `cyrius build src/main.cyr build/cyrius-polyomino`
5. Unit tests: `cyrius test` — deterministic + headless, must stay green
6. Benchmarks (if a hot path changed): `sh scripts/bench-history.sh`
7. **Playtest** — run the built binary on a Linux console. Gravity feel, DAS,
   and lock-delay timing are playtest concerns; a green test suite proves
   determinism, not that the game feels right (see *Playtest over unit test*).
8. Clean: `cyrius fmt <file> --check`, `cyrius lint src/*.cyr`, `cyrius vet src/main.cyr`
9. Submit a PR

## Project Structure

The M1 module layout (tracked in [`docs/development/state.md`](docs/development/state.md)):

```
src/piece.cyr      seven tetrominoes + rotation states (pure)
src/board.cyr      10x20 grid: collision, lock, line-clear
src/world.cyr      game state + step: RNG, spawn, move, rotate, gravity, scoring
src/score.cyr      line-clear scoring + level progression
src/framebuf.cyr   offscreen RGB surface + PPM dump
src/render.cyr     draw board + active piece
src/input.cyr      raw-tty keyboard input + pure key decoder
src/tick.cyr       ~60 fps frame pacing
src/present.cyr    best-effort /dev/fb0 blit
src/main.cyr       entry: interactive loop + headless smoke
```

See [`docs/development/roadmap.md`](docs/development/roadmap.md) for the
milestone sequence (M0 scaffold → M1–M2 classic core → M3 modern guideline
layer → M4 audio → M5 high-scores → M6 polish → v1.0).

## Playtest over unit test (for feel)

Unit tests prove **determinism and boundary conditions** — collision math,
buffer bounds, line-clear compaction, save-file roundtrips. Playtest proves the
game is **fun**. If a change touches gravity, DAS, lock delay, or the rotation
system, the PR must say how it played, not just that the tests pass.

## Determinism is load-bearing

The integer simulation core must stay bit-reproducible from a seed + input
stream (the replay / speedrun invariant). No floating-point in the simulation;
no wall-clock in the sim step. A change that makes a fixed seed + input produce
a different board state needs an explicit justification.

## Code Style

Follow the Cyrius conventions in [`CLAUDE.md`](CLAUDE.md):

- `var buf[N]` is N **bytes**, not N elements
- `&&` / `||` short-circuit; mixed conditions require parens
- No closures — named functions
- No negative literals — write `(0 - N)`, not `-N`
- Test exit pattern: `syscall(60, assert_summary())`
- Use `#` comments
- `cyrius fmt` is the arbiter of formatting; CI fails on drift

## Adding a Module

1. Create `src/mymodule.cyr`
2. `include` it from `src/main.cyr` in dependency order
3. Add unit tests in `tests/cyrius-polyomino.tcyr` (give each a `test_` prefix)
4. Build + test + playtest the path the module touches
5. Update [`CHANGELOG.md`](CHANGELOG.md) and, if a milestone boundary is
   crossed, [`docs/development/state.md`](docs/development/state.md)

## Commit Messages & CHANGELOG

Follow [Keep a Changelog](https://keepachangelog.com/) categories:

- `add: feature description` — new gameplay or systems
- `fix: bug description` — bug fixes
- `change: what changed` — modifications

## Security

Found a vulnerability? See [`SECURITY.md`](SECURITY.md) — report via GitHub
Security Advisories, not a public issue.

## License

By contributing, you agree that your contributions are licensed under
**GPL-3.0-only**.
