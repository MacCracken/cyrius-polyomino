# 0003 — Self-rolled primitives; defer kiran / impetus / mabda

**Status**: Accepted
**Date**: 2026-05-26

## Context

The Cyrius game stack — **kiran** (ECS engine + scene hierarchy + input),
**impetus** (rigid-body physics), **mabda** (GPU rendering), and a windowing
layer (**soorat**) — is the heavyweight path for in-depth game projects. At
toolchain 6.0.1 most of it is not buildable as a dependency here: kiran and
impetus are still Rust (Cyrius ports pending, no schedule), soorat is unwired,
and mabda is GPU-render-only — no window, no input, no game loop, so it cannot
make a playable game on its own. cyrius-bb hit exactly this and resolved it in
its own ADR 0003.

A falling-block puzzle is an even better fit for the lightweight path than a
brick-breaker: the entire simulation is a **fixed integer grid** (10×20 cells),
discrete gravity ticks, and row scans. There is no continuous physics, no
floating-point, no sub-cell collision. It is naturally deterministic.

Meanwhile **cyrius-doom** — a *shipped* retro port in this lineage — depends on
none of the heavy stack: it self-rolls its framebuffer (`/dev/fb0`), tick loop,
fixed-point math, and input on bare stdlib (+ vani for audio, bsp for geometry).

## Decision

**cyrius-polyomino tools its own primitives on bare Cyrius stdlib and does not
depend on kiran, impetus, mabda, or soorat.** The board model, piece logic,
randomizer, game loop, framebuffer rendering, and input live in `src/` and are
unit-tested headless — following the proven cyrius-doom / cyrius-bb pattern.

- **In scope now (M1–M3)**: integer grid board (`src/board.cyr`), tetromino +
  rotation logic (`src/piece.cyr`), seedable randomizer (`src/rng.cyr`), game
  state + step (`src/world.cyr`), scoring (`src/score.cyr`), offscreen
  framebuffer + render + input + tick (`src/framebuf.cyr`, `render.cyr`,
  `input.cyr`, `tick.cyr`, `present.cyr`).
- **Integer-only core**: the board is cell-indexed; gravity and locking are
  discrete. No fixed-point is needed for the grid itself (unlike cyrius-bb's
  continuous ball) — DAS/lock-delay timing uses integer tick counts.
- **Retained as real deps**: **vani** (M4 audio — already Cyrius-native),
  **sankoch** + **sigil** (M5 save-file compression + integrity hash — don't
  self-roll crypto/compression). Dormant deps stay commented out in
  `cyrius.cyml` until their milestone lands (an unused dep just adds link
  warnings + binary weight).
- **Deferred, not deleted**: kiran / impetus / mabda / soorat remain the path
  for later in-depth projects. If a future feature genuinely needs one, that's a
  new decision with its own ADR.

## Consequences

- **Positive** — unblocks the whole project immediately; no critical-path
  dependency on a pending Rust→Cyrius port.
- **Positive** — the simulation core is pure integer logic, so it is
  bit-deterministic and fully unit-testable without a window or framebuffer
  (CI-friendly, and it makes replays / speedruns exact — a v1.0 invariant).
- **Positive** — matches the AGNOS sovereignty stance end to end: no FFI, no GPU
  driver surface, no external engine.
- **Negative** — we own the rendering / input / loop code we'd otherwise
  inherit. Mitigated by the small scope (cyrius-doom's framebuf is ~145 lines;
  a grid renderer that draws flat cells needs a fraction of that).

## Alternatives considered

- **Wait for the kiran / impetus ports.** Rejected — no schedule; blocks
  indefinitely.
- **Use mabda for rendering, self-roll only the loop.** Rejected for the first
  cut — mabda still needs an unwired windowing layer and pulls GPU driver
  surface for a game that draws flat colored cells. A `/dev/fb0` framebuffer is
  enough; mabda stays available if a later visual treatment ever justifies it.
- **Floating-point grid coordinates.** Rejected — pointless for a discrete cell
  grid, and float risks cross-platform non-determinism that works against the
  replay / speedrun invariant. Integer cell indices are bit-identical
  everywhere.
