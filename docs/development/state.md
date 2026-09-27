# cyrius-polyomino — Current State

> Refreshed every release. CLAUDE.md is preferences/process/procedures
> (durable); this file is **state** (volatile).

## Version

**0.5.4 — toolchain bump to Cyrius 6.6.6 + dependency refresh** (cut
2026-09-26). No source changes. Pins Cyrius `6.6.2 → 6.6.6` (`lib/` +
`cyrius.lock` regenerated clean), re-vendors vani-core `0.9.9 → 1.2.5`
(hardening only on the six `audio_*` calls polyomino makes), and re-points the
earmarked M5 deps at their latest tags (sankoch 2.8.0, sigil 3.13.2). Game
behaviour is unchanged — the headless smoke's output and PPMs are
byte-identical across the bump. **0.6.0 stays reserved for the M5 high-score
milestone.** (Prior: 0.5.3 — Cyrius 6.3.5 → 6.6.2, Result value form,
2026-09-11; 0.5.2 — vani-core 0.9.6 → 0.9.9, 2026-07-04; 0.5.1 — Cyrius
6.2.2 → 6.3.5 + audio routed to card 1 device 0 via the `AudioDev` constants,
2026-06-29; 0.5.0 — M4 audio pass, 2026-06-14: square-wave synth + six SFX
cues routed to ALSA via vani's `audio_*` shim, vani **vendored** as a single
file (`vendor/vani-core.cyr`, `core` profile) to avoid the ~4× git-tree bloat;
0.4.0 — M3 modern guideline layer; 0.3.0 — M2 progression; 0.2.2/0.2.1 —
input/geometry fixes; 0.2.0 — M1 playable core; 0.1.0 — scaffold.) The version
files are bumped to 0.5.4; the git tag is the user's to create.

- **DCE binary**: 75,328 B (x86_64, static, stripped) — +256 B vs 0.5.3's 75,072 B (+192 toolchain, +64 the vani null-handle guards). 0.5.1 recorded 137,032 B on 6.3.5; the DCE build was already ~75 KB by 6.6.2, so that drop predates this cut. Vendoring vani-core rather than git-resolving it avoids a ~4× blowup (488 KB) from vani's transitive tree.
- **Tests**: 253 assertions, 0 failed (unchanged since 0.5.0's +18 for synth waveform/timing, SFX event byte counts + tone sample, mute toggle / no-device no-op, mute key decode). fmt + lint + vet clean.
- **Benchmarks** (6.6.6): piece_word 24ns · board_collides 51ns · board_clear_lines 177ns · render_world 381µs/frame. The two micro-ops are 1–2 ns slower than on 6.6.2 in every interleaved pair (compiler-side; source unchanged); render is flat. `bench-history.csv` last recorded 0.2.0; M4 audio is off the render hot path.
- **Security**: P(-1) audit clean — 0 CRIT/HIGH/MED, 2 LOW fixed ([2026-05-26 audit](../audit/2026-05-26-audit.md)). M4 adds no external input surface (synth is pure; vani-core opens `/dev/snd` read-of-caps only on a real device).
- **Deps**: bare stdlib (ten modules) + **vani-core 1.2.5 vendored** at `vendor/vani-core.cyr` (audio). sankoch / sigil re-wire at M5.
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

- **Cyrius pin**: `6.6.6` (in `cyrius.cyml [package].cyrius`) — bumped from 6.6.2 at the 0.5.4 cut; no source changes needed. The stdlib `lib/` is materialised by `cyrius deps`, not committed; `cyrius.lock` records the 27 resolved files plus a `cyrius 6.6.6` toolchain trailer.
- **`continue` in loop nests** (a toolchain hazard, not a polyomino bug): through 6.6.2 a nested loop's `continue` could miscompile, and 6.6.6 still miscompiles one shape — a `continue` in the innermost `for` of a `for > while > for` nest whose outer `for` has a `continue` before the `while`. 6.6.3+ also refuses more than 8 `continue`s in one nest. polyomino's only `continue` (`input_poll`) sits in a single un-nested `while`; keep new ones out of that shape (see cyrius-doom's `docs/audit/2026-09-26-toolchain-6.6.6-nested-continue.md`).
- **History**: 6.6.2 at 0.5.3 (Result value form); 6.3.5 at 0.5.1 (the `bench` harness became a manual include, so `tests/cyrius-polyomino.bcyr` and `benches/polyomino.bcyr` `include "lib/bench.cyr"` explicitly); 6.2.2 at 0.4.0; 6.0.1 before that.

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
- `src/audio.cyr` — **SFX event→note map (`sfx_render`) + vani playback shell + mute** (M4); device half is best-effort, no-ops with no `/dev/snd`. Opens card 1 device 0 by default (`AudioDev` constants, 0.5.1) — the verified analog target, not card 0 (often no PCM)
- `vendor/vani-core.cyr` — **vendored vani 1.2.5 `core` profile** (ALSA `audio_*` shim); single self-contained file, see `vendor/README.md`
- `src/input.cyr` / `src/tick.cyr` / `src/present.cyr` — raw-tty input + decoder (now incl. **hard drop = space, hold = c, mute = m**), ~60 fps pacing, geometry-probed (`FBIOGET_{V,F}SCREENINFO`) integer-scaled + centred `/dev/fb0` blit
- `src/main.cyr` — interactive loop (tick model + DAS + hard drop + hold + HUD + **audio cues** + game-over screen + line-clear flash) + deterministic headless `<frames> [seed]` smoke

Planned: `src/save.cyr` (M5, sankoch + sigil).

## Tests

- `tests/cyrius-polyomino.tcyr` — **253 assertions, 0 failed**: piece, board, rng (LCG + 7-bag permutation/two-bag stream), world (move/SRS rotate/gravity/clear/top-out), SRS (decode/transitions/wall+floor kick/boxed-fail), hard drop, hold, scoring (combo/B2B/T-spin), world tick, gravity curve, DAS, score helpers, render (pixels + ghost), HUD (multi-queue/HOLD/layout), **synth (waveform / ms→samples / decay)**, **audio (SFX byte counts / tone sample / mute toggle / no-device no-op)**, input (key decode incl. hard drop / hold / mute). Deterministic + headless.
- `tests/cyrius-polyomino.bcyr` — benchmark stub (no-op; `include`s `lib/bench.cyr` since 6.3.x; real benches at the P(-1) pass)
- `tests/cyrius-polyomino.fcyr` — fuzz stub
- Playtest gate: the interactive loop + `/dev/fb0` present need a real Linux console (build/lint + headless-smoke-verified only so far).

## Dependencies

Direct (declared in `cyrius.cyml`): bare stdlib — `string, alloc, fmt, io, fs,
str, vec, syscalls, args, assert` ([ADR 0003](../adr/0003-self-rolled-primitives.md)).

External: **vani-core vendored** as a single file (`vendor/vani-core.cyr`,
1.2.5 `core` profile, audio) rather than a git dep — see `vendor/README.md`
for why (transitive-tree bloat) and how to refresh.

Earmarked (commented out until their milestone): `sankoch` 2.8.0 + `sigil`
3.13.2 (M5 high-score save; tags track each repo's latest release). The 6.6.6
stdlib also bundles both (sankoch 2.8.0, sigil 3.12.18), an alternative to the
git deps for M5 to weigh.

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
   **Check first — sound may never play.** `audio_init` asks the raw `hw:1,0`
   PCM for 11025 Hz / mono / 8-bit, but the dev box's card-1 codec advertises
   only 16/20/24-bit at ≥ 32 kHz (`/proc/asound/card1/codec#0`), and a raw hw
   device does no rate/format conversion — so `HW_PARAMS` most likely fails
   (its return is unchecked) and every write is dropped. Separately,
   `synth.cyr` renders *unsigned* 8-bit (silence = 128) while vani's
   `bits = 8` programs *signed* S8 (vani 1.2.x adds `audio_set_params_fmt` for
   an explicit format). Found at 0.5.4 from the code + codec caps; unverified
   on hardware (that session had no `/dev/snd` access).
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
