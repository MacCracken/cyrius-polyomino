# 0001 — Original polyomino puzzle, mechanics from observation

**Status**: Accepted
**Date**: 2026-05-26

## Context

cyrius-polyomino is a falling-block puzzle game — the genre defined by the
1984 title built around the seven one-sided tetrominoes. That genre's name and
much of its presentation (the canonical piece palette, the theme tune, the
brand) are **actively enforced trademarks** held by The Tetris Company. The
mechanics themselves — a well, gravity, the seven tetrominoes, row clears,
level-based speed-up, modern guideline rotation/scoring — are widely
documented in public sources (design retrospectives, the publicly published
guideline, decades of clones and reference implementations).

The project is named **polyomino**, not after the trademarked title, which is a
deliberate signal: we want the genre, not the brand.

## Decision

**cyrius-polyomino is an original falling-block puzzle reimplemented from
observation of the genre's documented public mechanics. It is not branded as,
and does not present itself as, the trademarked title.**

- **In scope**: the standard well geometry (10×20 visible), the seven
  tetrominoes, gravity / soft drop / hard drop, line clears, level speed
  curves, and the modern guideline behaviors (SRS-style rotation + wall kicks,
  7-bag, hold, ghost) — all sourced from public documentation and cited inline.
- **Naming**: generic genre language ("polyomino", "tetromino", "falling-block
  puzzle"). No trademarked product name in the binary, docs, or marketing.
- **Out of scope**: the trademarked name, the canonical theme tune, and any
  asset that pattern-matches the brand's distinctive presentation (covered
  separately in [ADR 0002](0002-original-assets-only.md)).

This mirrors cyrius-bb's homage-from-observation thesis (its ADR 0001): a
structurally-faithful homage built from documented mechanics, never a
reverse-engineered port.

## Consequences

- **Positive** — clean of trademark exposure; the project can ship and be
  described publicly without brand entanglement. The "polyomino" framing is
  also more honest about what the code *is*: a polyomino grid simulator.
- **Positive** — citing mechanics to public sources (guideline doc, scoring
  tables, gravity curves) forces the same source-discipline AGNOS applies to
  science/math crates; a reviewer can verify each rule against its origin.
- **Negative** — we forgo the instant recognition of the brand name. Mitigated:
  the genre is recognizable from one screenshot regardless of naming.
- **Neutral** — some mechanics (e.g. the gravity table, SRS kick offsets) are
  conventions with a canonical published form; we implement the published
  *behavior*, cite it, and document any deviation in `docs/standards/`.

## Alternatives considered

- **Brand it as a "<trademark> homage".** Rejected — invites enforcement from a
  company known to pursue clones aggressively, for no engineering benefit.
- **Invent novel mechanics to differentiate.** Rejected — the goal is a
  faithful genre homage and a Cyrius game-stack demonstration, not a new puzzle
  design. Novelty lives in the *implementation* (deterministic integer core,
  self-rolled on bare stdlib), not the rules.
