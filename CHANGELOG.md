# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Project identity set: an original falling-block puzzle in Cyrius — a generic, trademark-clean homage to the 1984-era genre (not branded as the trademarked title).
- ADR 0001 (original puzzle, mechanics from observation), ADR 0002 (original assets only), ADR 0003 (self-rolled primitives; defer kiran / impetus / mabda) — mirroring the cyrius-bb / cyrius-doom pattern.
- Roadmap through v1.0: M0 scaffold → M1–M2 classic playable core → M3 modern guideline layer (SRS, 7-bag, hold, ghost, hard drop) → M4 audio → M5 high-scores → M6 polish.

### Changed
- `cyrius.cyml`: filled in `description`, switched `version` to `${file:VERSION}`, added `repository`, fixed `output` to `build/cyrius-polyomino`, removed a stray `---` line, and documented the earmarked external deps (vani / sankoch / sigil) as commented-out blocks.
- `CLAUDE.md`, `README.md`, `docs/development/state.md`: filled in from `cyrius init` placeholders to reflect the project identity, self-rolled approach, Cyrius conventions, and homage/assets constraints.

## [0.1.0]

### Added
- Initial project scaffold
