# cyrius-polyomino — Claude Code Instructions

> **Core rule**: this file is **preferences, process, and procedures** —
> durable rules that change rarely. Volatile state (current version,
> module line counts, supported backends, test counts, dep-gap status,
> consumers) lives in [`docs/development/state.md`](docs/development/state.md).
> Do not inline state here.

## Project Identity

**cyrius-polyomino** — an original falling-block puzzle game in Cyrius. A
*polyomino* is unit cells joined edge-to-edge; the four-cell tetromino (I, O,
T, S, Z, J, L) is the genre's building block. Generic homage to the 1984-era
falling-block puzzle genre — **not** branded as the trademarked title.

- **Type**: Binary (game)
- **License**: GPL-3.0-only
- **Language**: Cyrius (toolchain pinned in `cyrius.cyml [package].cyrius`)
- **Version**: `VERSION` at the project root is the source of truth — do not inline the number here
- **Genesis repo**: [agnosticos](https://github.com/MacCracken/agnosticos)
- **Standards**: [First-Party Standards](https://github.com/MacCracken/agnosticos/blob/main/docs/development/first-party/first-party-standards.md) · [First-Party Documentation](https://github.com/MacCracken/agnosticos/blob/main/docs/development/first-party/first-party-documentation.md)
- **Siblings**: [cyrius-doom](https://github.com/MacCracken/cyrius-doom) (engine novelty), [cyrius-bb](https://github.com/MacCracken/cyrius-bb) (accessible-scope brick-breaker) — same retro-game-in-Cyrius lineage and self-rolled pattern

## Goal

Ship a complete, deterministic falling-block puzzle in Cyrius. The simulation
core is **pure integer grid logic** — a 10×20 well, seven tetrominoes, gravity,
line clears, scoring — so it is bit-deterministic and fully unit-testable
headless. The build is MVP-first: a *classic* playable core (M1–M2), then the
*modern guideline* layer (SRS rotation, 7-bag, hold, ghost, hard drop) on top
(M3). Renderer, input, and loop are self-rolled on bare stdlib ([ADR 0003](docs/adr/0003-self-rolled-primitives.md)),
following the proven cyrius-doom / cyrius-bb path — no engine, no GPU, no FFI.

The homage surface: structural fidelity to the genre's *documented public
mechanics* (well geometry, rotation systems, scoring tables, gravity curves),
captured in [ADR 0001](docs/adr/0001-original-puzzle-from-observation.md).
Original assets only ([ADR 0002](docs/adr/0002-original-assets-only.md)).

## Current State

> Volatile state lives in [`docs/development/state.md`](docs/development/state.md) —
> current version, surface area, in-flight work, consumers, dep gaps.
> Refreshed every release.

This file (`CLAUDE.md`) is durable rules.

## Scaffolding

Project was scaffolded with `cyrius init` (greenfield) or `cyrius port` (Rust → Cyrius migration). **Do not manually create project structure** — use the tools. If a tool is missing something, fix the tool.

## Quick Start

```sh
cyrius deps                          # resolve sibling deps
cyrius build src/main.cyr build/cyrius-polyomino
cyrius test                          # run [build].test + tests/*.tcyr
```

## Key Principles

- **Correctness over cleverness** — if it's wrong, the bugs own you
- Test after every change, not after the feature is "done"
- ONE change at a time — never bundle unrelated changes
- Research before implementation — Cyrius language references live in the [vidya](https://github.com/MacCracken/vidya) and [cyrius](https://github.com/MacCracken/cyrius) repos; check those + the sibling games (cyrius-doom, cyrius-bb) for existing patterns before inventing
- **Determinism is load-bearing** — the integer grid core must be bit-reproducible from a seed + input stream (the replay / speedrun invariant). No floating-point in the simulation, no wall-clock in the sim step
- **Feel is playtest territory** — gravity curves, DAS, and lock-delay timing need to feel right to a human; unit tests prove determinism and boundaries, playtest proves it's fun
- Build with `cyrius build`, not raw `cat file | cc5` — the manifest auto-resolves deps and prepends includes
- Source files only need project includes — stdlib / external deps auto-resolve from `cyrius.cyml`
- Every buffer declaration is a contract: `var buf[N]` = N **bytes**, not N entries
- `&&` / `||` short-circuit; mixed expressions require explicit parens

## Rules (Hard Constraints)

- **Read the genesis repo's CLAUDE.md first** — [agnosticos/CLAUDE.md](https://github.com/MacCracken/agnosticos/blob/main/CLAUDE.md)
- **Do not commit or push** — the user handles all git operations
- **Never use `gh` CLI** — use `curl` to the GitHub API if needed
- **Not branded as the trademarked title** — generic genre language only (polyomino / tetromino / falling-block). Mechanics from documented public sources, never reverse-engineered ([ADR 0001](docs/adr/0001-original-puzzle-from-observation.md))
- **Original assets only** — no trademarked names, palettes, sprites, or the canonical theme tune ([ADR 0002](docs/adr/0002-original-assets-only.md))
- **No FFI, no engine deps on the critical path** — self-rolled on bare stdlib; kiran / impetus / mabda deferred ([ADR 0003](docs/adr/0003-self-rolled-primitives.md)). vani / sankoch / sigil are the only earmarked external deps (audio + save, M4–M5)
- Do not skip tests before claiming changes work
- Do not use `sys_system()` with unsanitized input — command injection
- Do not trust external data (file / network / args) without validation — save files are validated + sigil-hash-checked before load
- Do not commit or hand-edit `lib/` — it is the resolved stdlib snapshot, **gitignored** and materialised by `cyrius deps` from the version-pinned toolchain (`cyrius.cyml [package].cyrius`). A committed copy goes stale vs the pinned compiler's own stdlib (the `cwd ./lib/ shadows version-pinned …` build note). Run `cyrius deps` to (re)materialise it; CI does this every run.
- Do not hardcode toolchain versions in CI YAML — `cyrius = "X.Y.Z"` in `cyrius.cyml` is the source of truth
- Do not inline volatile state in this file — `docs/development/state.md` is the home

## Cyrius Conventions

- `var buf[N]` is N **bytes**, not N elements
- `&&` / `||` short-circuit; mixed expressions require explicit parens
- No closures — named functions
- No negative literals — `(0 - N)`, not `-N`
- Test exit pattern: `syscall(60, assert_summary())`
- Deps are prepended as includes in declaration order (single-pass compiler) — `string`/`alloc` before anything using `strlen`/`alloc`/`memcpy`

## Documentation

- [`docs/adr/`](docs/adr/) — Architecture Decision Records (*why X over Y?*). Start with [0001](docs/adr/0001-original-puzzle-from-observation.md) (puzzle-from-observation), [0002](docs/adr/0002-original-assets-only.md) (original-assets-only), [0003](docs/adr/0003-self-rolled-primitives.md) (self-rolled primitives).
- [`docs/architecture/`](docs/architecture/) — Non-obvious constraints (*what's true about the code?*)
- [`docs/guides/`](docs/guides/) — Task-oriented how-tos
- [`docs/examples/`](docs/examples/) — Runnable examples
- [`docs/development/state.md`](docs/development/state.md) — Live state snapshot
- [`docs/development/roadmap.md`](docs/development/roadmap.md) — Milestone arc (M0 scaffold → M1–M2 classic core → M3 modern guideline layer → M4 audio → M5 high-scores → M6 polish → v1.0)

## Process

1. **Work phase** — features, roadmap items, bug fixes
2. **Build check** — `cyrius build`
3. **Test + benchmark additions** for new code
4. **Internal review** — performance, memory, correctness, edge cases
5. **Documentation** — update CHANGELOG, `docs/development/state.md`, any ADR the change earned
6. **Version sync** — `VERSION`, `cyrius.cyml`, CHANGELOG header

