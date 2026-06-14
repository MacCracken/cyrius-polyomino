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

**Shape of the plan**: an MVP-first ramp — a *classic* playable game first
(M1–M2), then the *modern guideline* layer on a proven core (M3), then audio
(M4), high-score save (M5), and polish (M6). Shipped through M4; M5–M6 remain.

## v1.0 criteria

- [ ] All milestones M1–M6 complete (M1–M4 done; M5 save + M6 polish remain)
- [ ] Public-facing behavior frozen — board geometry, scoring table, and rotation system documented and tested (documented + tested; freeze is a v1.0 act)
- [x] Deterministic headless simulation: a fixed input + seed sequence produces a byte-identical board state and score (the speedrun/replay invariant)
- [x] Test coverage adequate for the surface area (≥100 assertions; every module's logic exercised headless) — 253 assertions
- [ ] Benchmarks captured (board step, line-clear scan, collision) — `bench-history.csv` seeded; promote to `docs/benchmarks.md`
- [ ] Interactive console playthrough verified on a real Linux `/dev/fb0` console + sound card (top-out, level-up, line-clear feel, SFX timing)
- [x] CHANGELOG complete from v0.1.0 onward
- [ ] Security audit pass covering the M3/M4 code (`docs/audit/YYYY-MM-DD-audit.md`; the 2026-05-26 P(-1) pass predates them)
- [x] Original assets only — no trademarked names, sprites, palettes, or the canonical theme tune ([ADR 0002](../adr/0002-original-assets-only.md))

## Milestones

### Shipped (M0–M4)

The classic core, the modern guideline layer, and audio are all in — per-release
detail in [`CHANGELOG.md`](../../CHANGELOG.md); live surface in [`state.md`](state.md).

| Milestone | Version | Date | Summary |
|-----------|---------|------|---------|
| M0 — Scaffold | 0.1.0 | 2026-05-26 | `cyrius init`, identity, ADRs 0001–0003, doc tree, toolchain pin |
| M1 — Playable core | 0.2.0 | 2026-05-26 | deterministic integer core + self-rolled I/O; pieces fall/lock/clear, top-out; P(-1) hardening |
| M2 — Progression & feel | 0.3.0 | 2026-06-03 | per-level gravity curve, DAS, lock delay, HUD (score/level/lines + next), clear flash, game-over screen |
| M3 — Modern guideline layer | 0.4.0 | 2026-06-14 | SRS wall kicks, 7-bag, hold, ghost, hard drop, multi-NEXT, T-spin/B2B/combo scoring |
| M4 — Audio pass | 0.5.0 | 2026-06-14 | original square-wave SFX cues via vendored vani, mute toggle |

**Carried forward from shipped milestones** (not blocking; mostly playtest-gated):

- **Console playtest** on a real Linux `/dev/fb0` + sound card — tune the M2/M3
  *feel* (gravity / DAS / lock-delay constants, SRS kick feel) and M4 *audio*
  (SFX timing/mix, blocking-write smoothness at 60 fps). The sim is proven
  headless; *fun* is proven on console.
- **Richer per-row line-clear animation** — needs splitting the
  lock/detect/clear steps in `world.cyr` (today it locks-then-clears in one
  step, so M2's flash strobes the whole well border).
- **Optional user `.ogg` music** slot (`~/.cyrius-polyomino/music/`, silent by
  default) — deferred from M4; needs an Ogg decoder.

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

**Target date**: _not yet pinned._ M1–M4 landed quickly; what remains is M5
(save), M6 (polish), and the console-playtest pass. Candidate narrative anchor
— the genre's origin (Alexey Pajitnov, June 1984).

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
| M1–M3 | bare Cyrius stdlib (self-rolled core) | ✅ done |
| M4 | `vani` (audio device I/O) | ✅ done — vendored as `vendor/vani-core.cyr` (0.9.5 `core`) |
| M5 | `sankoch` (compression), `sigil` (integrity hash) | ✅ available |

No part of the critical path is blocked on a pending Rust→Cyrius port — the
self-rolled decision ([ADR 0003](../adr/0003-self-rolled-primitives.md)) keeps
the core on bare stdlib, and the audio/save deps are already Cyrius-native.

See [ADR 0001](../adr/0001-original-puzzle-from-observation.md) for the
homage-from-observation thesis, [ADR 0002](../adr/0002-original-assets-only.md)
for the assets policy, [ADR 0003](../adr/0003-self-rolled-primitives.md) for the
self-rolled-primitives decision, and [`state.md`](state.md) for live progress.
