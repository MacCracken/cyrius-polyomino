# 0002 — Original assets only

**Status**: Accepted
**Date**: 2026-05-26

## Context

[ADR 0001](0001-original-puzzle-from-observation.md) establishes that
cyrius-polyomino is an original homage built from documented public mechanics,
not a branded product. The same discipline has to extend to *assets* — art,
audio, palettes, and the theme tune — or the trademark-cleanliness of the code
is undone by the presentation layer. The genre's canonical block palette, its
distinctive piece-color assignments, and especially its theme tune are part of
what the brand protects; the well-known theme melody is a public-domain folk
tune ("Korobeiniki") but its *association* with the brand and specific arranged
versions carry their own baggage.

## Decision

**All art, audio, palettes, and music in cyrius-polyomino are original work,
drawn from public-domain reference, or commissioned with a clear license. No
asset is ripped from, or made to pass for, the trademarked product.**

- **Art**: original block art and palette. We do not pixel-match the canonical
  per-piece colors; we choose an original, color-blind-friendly palette (M6).
- **Audio**: original square-wave / FM sound effects synthesized in-engine (M4).
- **Music**: the canonical theme tune is **not** shipped. Any bundled music is
  original composition; user-supplied music is opt-in via a slot directory and
  silent-by-default if absent.
- **No ML-generated derivatives** of the brand's art or audio.

Mirrors cyrius-bb's ADR 0002 (original-assets-only), adapted for the
falling-block genre's specific trademark surface (palette + theme tune).

## Consequences

- **Positive** — presentation is as trademark-clean as the mechanics; the
  project can ship art and audio publicly without exposure.
- **Positive** — an original color-blind-friendly palette is an accessibility
  win the canonical palette doesn't offer (M6 accessibility pass).
- **Negative** — we author or commission every asset rather than reaching for
  the familiar ones. Mitigated by the deliberately small asset surface (seven
  block colors, a handful of SFX, an optional theme).
- **Neutral** — placeholder solid-color cells stand in until the M6 art pass;
  that's a known temporary state, not a shipped asset.

## Alternatives considered

- **Ship the canonical palette + theme for instant familiarity.** Rejected —
  reintroduces exactly the trademark exposure [ADR 0001](0001-original-puzzle-from-observation.md)
  was written to avoid.
- **Use the public-domain Korobeiniki melody as the default theme.** Rejected
  as a *default* — the tune is public domain, but its brand association makes
  shipping it as the headline theme read as the trademarked product. Kept as an
  option a user could drop into the music slot themselves, not bundled.
