# cyrius-polyomino — Current State

> Refreshed every release. CLAUDE.md is preferences/process/procedures
> (durable); this file is **state** (volatile).

## Version

**0.5.0 — M4 audio pass** (cut 2026-06-14). Adds era-spirit sound on the
proven core: original square-wave synthesis (`synth.cyr` — 8-bit mono PCM,
linear-decay blips, ADR 0002: no sampled audio) and an event→note SFX map
(`audio.cyr`) for the six cues (move/rotate, lock thud, line-clear chime,
quad fanfare, level-up, top-out), routed to ALSA via vani's `audio_*` shim.
The synth + event mapping are pure and headless-tested (253 assertions, up
from 235); the device layer is best-effort and silent without a sound card
(CI / no `/dev/snd`), like `present.cyr`. Mute on `m`. vani is **vendored as a
single file** (`vendor/vani-core.cyr`, the playback `core` profile) instead of
a git dep — the full git tree (patra+yukti+sakshi) bloated the binary ~4×
since DCE can't prune vendored modules. (Prior: 0.4.0 — M3 modern guideline
layer, 2026-06-14: SRS wall kicks, 7-bag, hold, ghost, hard drop, multi-NEXT,
T-spin/B2B/combo; 235 assertions; toolchain pinned 6.2.2 + CI repaired +
`lib/` untracked. 0.3.0 — M2 progression & feel, 2026-06-03. 0.2.2 —
interactive-loop input fix. 0.2.1 — framebuffer geometry fix. 0.2.0 — M1
playable core, 2026-05-26. 0.1.0 — scaffold.) The version files are bumped to
0.5.0; the git tag is the user's to create.

- **DCE binary**: 136,512 B (x86_64, static, stripped) — +24,296 B vs 0.4.0 (synth + SFX + the vendored vani-core ALSA shim). Vendoring vani-core rather than git-resolving it avoids a ~4× blowup (488 KB) from vani's transitive tree.
- **Tests**: 253 assertions, 0 failed (+18 for synth waveform/timing, SFX event byte counts + tone sample, mute toggle / no-device no-op, mute key decode). fmt + lint + vet clean.
- **Benchmarks**: piece_word 22ns · board_collides 48ns · board_clear_lines 173ns · render_world 381µs/frame (`bench-history.csv`; M4 audio is off the render hot path).
- **Security**: P(-1) audit clean — 0 CRIT/HIGH/MED, 2 LOW fixed ([2026-05-26 audit](../audit/2026-05-26-audit.md)). M4 adds no external input surface (synth is pure; vani-core opens `/dev/snd` read-of-caps only on a real device).
- **Deps**: bare stdlib (ten modules) + **vani-core vendored** at `vendor/vani-core.cyr` (audio). sankoch / sigil re-wire at M5.
- **Caveat**: the interactive loop + `/dev/fb0` present are confirmed running
  live on a real console (0.2.2). The M2/M3 *feel* layers and the new M4
  *audio* layer — SFX timing/mix as it lands during play, and whether the
  blocking ALSA writes (e.g. the ~240 ms fanfare, per-frame move blips on DAS
  auto-repeat) stay smooth at 60 fps — build + headless-test but want a
  console playtest to tune. Known tty limitation: a raw terminal has no
  key-release event, so DAS and soft-drop "hold" ride the kernel autorepeat
  stream (documented in `das.cyr`). In dev/CI (no console/framebuffer/sound)
  the simulation is proven by the 253 deterministic assertions + the seedable
  `<frames>` smoke (varies by seed; renders a valid 210×240 PPM); `audio_play`
  no-ops with no device, so the headless path never touches sound.

## Toolchain

- **Cyrius pin**: `6.2.2` (in `cyrius.cyml [package].cyrius`) — bumped from 6.0.1 at the 0.4.0 cut (clears the 6.0.1↔wrapper drift; CI installs the pin via the upstream `install.sh`). The stdlib `lib/` is materialised by `cyrius deps`, not committed.

## Source

M1–M4 complete on the dev tip — the deterministic integer core + self-rolled
I/O + progression/feel + the modern guideline layer + audio, per
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
- `src/synth.cyr` — **square-wave PCM synthesis** (8-bit mono, decay envelope; pure) (M4)
- `src/audio.cyr` — **SFX event→note map (`sfx_render`) + vani playback shell + mute** (M4); device half is best-effort, no-ops with no `/dev/snd`
- `vendor/vani-core.cyr` — **vendored vani 0.9.5 `core` profile** (ALSA `audio_*` shim); single self-contained file, see `vendor/README.md`
- `src/input.cyr` / `src/tick.cyr` / `src/present.cyr` — raw-tty input + decoder (now incl. **hard drop = space, hold = c, mute = m**), ~60 fps pacing, geometry-probed (`FBIOGET_{V,F}SCREENINFO`) integer-scaled + centred `/dev/fb0` blit
- `src/main.cyr` — interactive loop (tick model + DAS + hard drop + hold + HUD + **audio cues** + game-over screen + line-clear flash) + deterministic headless `<frames> [seed]` smoke

Planned: `src/save.cyr` (M5, sankoch + sigil).

## Tests

- `tests/cyrius-polyomino.tcyr` — **253 assertions, 0 failed**: piece, board, rng (LCG + 7-bag permutation/two-bag stream), world (move/SRS rotate/gravity/clear/top-out), SRS (decode/transitions/wall+floor kick/boxed-fail), hard drop, hold, scoring (combo/B2B/T-spin), world tick, gravity curve, DAS, score helpers, render (pixels + ghost), HUD (multi-queue/HOLD/layout), **synth (waveform / ms→samples / decay)**, **audio (SFX byte counts / tone sample / mute toggle / no-device no-op)**, input (key decode incl. hard drop / hold / mute). Deterministic + headless.
- `tests/cyrius-polyomino.bcyr` — benchmark stub (no-op; real benches at the P(-1) pass)
- `tests/cyrius-polyomino.fcyr` — fuzz stub
- Playtest gate: the interactive loop + `/dev/fb0` present need a real Linux console (build/lint + headless-smoke-verified only so far).

## Dependencies

Direct (declared in `cyrius.cyml`): bare stdlib — `string, alloc, fmt, io, fs,
str, vec, syscalls, args, assert` ([ADR 0003](../adr/0003-self-rolled-primitives.md)).

External: **vani-core vendored** as a single file (`vendor/vani-core.cyr`,
0.9.5 `core` profile, audio) rather than a git dep — see `vendor/README.md`
for why (transitive-tree bloat) and how to refresh.

Earmarked (commented out until their milestone): `sankoch` + `sigil` (M5
high-score save).

## Consumers

_None — this is a leaf binary (game)._

## Next

See [`roadmap.md`](roadmap.md). Immediate sequence:

1. **M2–M4 console playtest** — verify on a real Linux console that the M2/M3
   *feel* (speed ramp, lock delay, DAS, soft drop, SRS kicks, hold, hard drop,
   ghost, T-spin/B2B/combo scoring) and the new M4 *audio* (the six SFX cues
   landing in time, mix balance, mute, and whether blocking ALSA writes stay
   smooth at 60 fps — esp. the fanfare and per-frame move blips on DAS
   auto-repeat) all feel right. Tune `gravity.cyr` / `das.cyr` / the SFX
   note tables accordingly.
2. **M5 — high-score persistence** (v0.6.0): `src/save.cyr` — top-10 table at
   `~/.cyrius-polyomino/scores.cyb`, sankoch-compressed + sigil-hashed, with
   tamper detection and a score-entry UI on a qualifying game-over.

Deferred (not blocking): M3's richer per-row line-clear animation (needs
splitting lock/detect/clear in `world.cyr`); M4's optional user `.ogg` music
slot from `~/.cyrius-polyomino/music/` (silent by default — needs an Ogg
decoder, out of scope for the M4 SFX cut).

Resolved at the 0.2.0 cut: benchmarks + CSV trail, P(-1) security audit (2 LOW
fixed), and the `CONTRIBUTING` / `CODE_OF_CONDUCT` / `SECURITY` root files
(`cyrius init` 6.0.1 does not emit these three — sourced from the cyrius-bb
template lineage and adapted).
