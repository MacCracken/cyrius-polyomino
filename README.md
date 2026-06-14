# cyrius-polyomino

> An original falling-block puzzle game in Cyrius. Generic homage to the
> 1984-era genre — built from documented public mechanics, not the brand.

---

## What this is

`cyrius-polyomino` is a falling-block puzzle reimplemented from observation, in
[Cyrius](https://github.com/MacCracken/cyrius). A *polyomino* is unit cells
joined edge-to-edge; the four-cell case — the **tetromino** — is the genre's
building block (the seven one-sided tetrominoes: I, O, T, S, Z, J, L).

Same retro-game-in-Cyrius lineage as [cyrius-doom](https://github.com/MacCracken/cyrius-doom)
(engine novelty) and [cyrius-bb](https://github.com/MacCracken/cyrius-bb)
(accessible-scope brick-breaker). The simulation core is a **pure integer
grid** — a 10×20 well, gravity, line clears, scoring — so it is
bit-deterministic and fully unit-testable headless, with the renderer, input,
and loop self-rolled on bare stdlib.

## What this isn't

- **Not branded as the trademarked title.** This is an original homage to the
  genre's *documented mechanics* — generic naming only (polyomino / tetromino /
  falling-block), no trademarked product name. See [ADR 0001](docs/adr/0001-original-puzzle-from-observation.md).
- **Not using the canonical assets.** All art, audio, palette, and music are
  original or licensed. The canonical block palette and theme tune are not
  shipped. See [ADR 0002](docs/adr/0002-original-assets-only.md).
- **Not a 3D / perspective game.** A flat orthogonal grid. Scope kept modest.

## How it's built

**Bare Cyrius stdlib — self-rolled core.** Per [ADR 0003](docs/adr/0003-self-rolled-primitives.md),
cyrius-polyomino tools its own board model, piece logic, randomizer, game loop,
framebuffer renderer, and input rather than depending on the heavier game stack
— following the proven cyrius-doom / cyrius-bb pattern. A discrete cell grid
doesn't need an ECS engine or a rigid-body physics crate.

Two first-party crates are earmarked for later milestones:

| Crate | Purpose | When |
|-------|---------|------|
| [vani](https://github.com/MacCracken/vani)     | Audio device I/O (sound effects)      | M4 |
| [sankoch](https://github.com/MacCracken/sankoch) | High-score file compression          | M5 |
| [sigil](https://github.com/MacCracken/sigil)   | High-score integrity hash             | M5 |

Deferred to later, more in-depth projects (not this one): [mabda](https://github.com/MacCracken/mabda)
(GPU), [kiran](https://github.com/MacCracken/kiran) (engine), [impetus](https://github.com/MacCracken/impetus)
(physics).

No C. No FFI. Cyrius stdlib end to end.

## Build

```sh
cyrius deps                                          # resolve stdlib deps
cyrius build src/main.cyr build/cyrius-polyomino     # compile
cyrius test                                          # run [build].test + tests/*.tcyr
```

## Status

**0.5.0 — M4 audio pass.** The classic core (M1–M2) + the modern layer (M3:
SRS kicks, 7-bag, hold, ghost, hard drop, multi-NEXT, T-spin/B2B/combo) + M4
audio: original square-wave SFX cues (move/rotate, lock, line-clear, quad
fanfare, level-up, top-out) routed through vani, with a mute toggle.
Deterministic integer core, 253 headless assertions. See
[`docs/development/roadmap.md`](docs/development/roadmap.md) for the milestone
arc and [`docs/development/state.md`](docs/development/state.md) for live
progress.

**Controls:** `a`/`d` or ←/→ move · `s` or ↓ soft drop · space hard drop ·
`w`/↑ rotate CW · `z` rotate CCW · `c` hold · `m` mute · `q`/Esc quit.

## License

GPL-3.0-only.

---

*Part of [AGNOS](https://github.com/MacCracken/agnosticos). See also:
[cyrius-doom](https://github.com/MacCracken/cyrius-doom),
[cyrius-bb](https://github.com/MacCracken/cyrius-bb).*
