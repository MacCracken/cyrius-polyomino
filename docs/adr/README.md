# Architecture Decision Records

Decisions about cyrius-polyomino — what we chose, the context, and the consequences we accept. Use these when a future reader would reasonably ask *"why did we do it this way?"*

## Conventions

- **Filename**: `NNNN-kebab-case-title.md`, zero-padded to four digits. Never renumber.
- **One decision per ADR.** If a decision supersedes a prior one, add a new ADR and set the old one's status to `Superseded by NNNN`.
- **Status lifecycle**: `Proposed` → `Accepted` → (optionally) `Superseded` or `Deprecated`.
- Use [`template.md`](template.md) as the starting point.

## ADR vs. architecture note vs. guide

| Kind | Lives in | Answers |
|---|---|---|
| ADR | `docs/adr/` | *Why did we choose X over Y?* |
| Architecture note | `docs/architecture/` | *What non-obvious constraint is true about the code?* |
| Guide | `docs/guides/` | *How do I do X?* |

## Index

- [0001 — Original polyomino puzzle, mechanics from observation](0001-original-puzzle-from-observation.md) — homage built from documented public mechanics; not branded as the trademarked title.
- [0002 — Original assets only](0002-original-assets-only.md) — all art / audio / palette / music is original or licensed; the canonical palette and theme tune are not shipped.
- [0003 — Self-rolled primitives; defer kiran / impetus / mabda](0003-self-rolled-primitives.md) — integer grid core on bare stdlib (cyrius-doom / cyrius-bb pattern); vani / sankoch / sigil retained as real deps for later milestones.
