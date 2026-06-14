# SRS rotation + wall-kick reference

> Pinned public reference for the rotation system implemented in
> [`src/srs.cyr`](../../src/srs.cyr). Per [ADR 0001](../adr/0001-original-puzzle-from-observation.md),
> every mechanic traces to a documented public source; this is that source
> for the modern rotation layer (M3). Reimplemented from the published
> guideline description — no trademarked assets ([ADR 0002](../adr/0002-original-assets-only.md)).

## What SRS is

The **Super Rotation System** is the modern falling-block guideline's
rotation standard. Two rules matter:

1. **Piece geometry** — each tetromino occupies fixed cells within a bounding
   box (4×4 for I, 3×3 for J/L/S/T/Z, 2×2 for O) for each of four rotation
   states (spawn, CW, 180, CCW). `src/piece.cyr` already stores the pieces in
   these SRS coordinates.
2. **Wall kicks** — when a basic rotation would collide, the piece is retried
   at a short ordered list of offset "kicks"; the first offset that fits is
   taken, otherwise the rotation fails. This is what lets pieces rotate
   against walls, the floor, and into tuck/spin slots.

O does not rotate (rotation-invariant), so it never kicks.

## Coordinate convention

The published kick tables use screen coordinates with **+y pointing up**.
This engine's board is **row-down** (row 0 = top, +y = down). `src/srs.cyr`
stores every offset **already converted** to row-down (`dy_board = -dy_up`),
so a caller adds `(dx, dy)` straight to the piece origin.

## Kick tables (board-space, row-down +y)

Each rotation transition lists five tests in order. Test 0 is always `(0,0)`
(the no-kick attempt). `from>to` uses rotation ids `0`=spawn `1`=CW `2`=180
`3`=CCW.

### J, L, S, T, Z (shared)

| transition | test 0 | test 1 | test 2 | test 3 | test 4 |
|------------|--------|--------|--------|--------|--------|
| 0>1 | (0,0) | (-1,0) | (-1,-1) | (0,+2) | (-1,+2) |
| 1>0 | (0,0) | (+1,0) | (+1,+1) | (0,-2) | (+1,-2) |
| 1>2 | (0,0) | (+1,0) | (+1,+1) | (0,-2) | (+1,-2) |
| 2>1 | (0,0) | (-1,0) | (-1,-1) | (0,+2) | (-1,+2) |
| 2>3 | (0,0) | (+1,0) | (+1,-1) | (0,+2) | (+1,+2) |
| 3>2 | (0,0) | (-1,0) | (-1,+1) | (0,-2) | (-1,-2) |
| 3>0 | (0,0) | (-1,0) | (-1,+1) | (0,-2) | (-1,-2) |
| 0>3 | (0,0) | (+1,0) | (+1,-1) | (0,+2) | (+1,+2) |

### I

| transition | test 0 | test 1 | test 2 | test 3 | test 4 |
|------------|--------|--------|--------|--------|--------|
| 0>1 | (0,0) | (-2,0) | (+1,0) | (-2,+1) | (+1,-2) |
| 1>0 | (0,0) | (+2,0) | (-1,0) | (+2,-1) | (-1,+2) |
| 1>2 | (0,0) | (-1,0) | (+2,0) | (-1,-2) | (+2,+1) |
| 2>1 | (0,0) | (+1,0) | (-2,0) | (+1,+2) | (-2,-1) |
| 2>3 | (0,0) | (+2,0) | (-1,0) | (+2,-1) | (-1,+2) |
| 3>2 | (0,0) | (-2,0) | (+1,0) | (-2,+1) | (+1,-2) |
| 3>0 | (0,0) | (+1,0) | (-2,0) | (+1,+2) | (-2,-1) |
| 0>3 | (0,0) | (-1,0) | (+2,0) | (-1,-2) | (+2,+1) |

These map one-to-one onto `srs_word_jlstz` / `srs_word_i` in `src/srs.cyr`
(encoded as packed bytes; see the module header for the packing).

## T-spin detection (3-corner rule)

A **T-spin** is scored when a T-piece is locked and:

1. its last successful action was a **rotation** (not a shift or a fall), and
2. at least **three of the four corners** of its 3×3 box are solid (a wall,
   the floor, or a filled cell).

**Mini vs proper.** The two corners on the side the T points toward are the
"front" corners. If **both front corners** are solid it is a **proper**
T-spin; if only one is, it is a **mini** — *unless* the rotation used the
outermost kick (test 4), which promotes a mini to proper. This is
implemented in `world_tspin_kind` (`src/world.cyr`) using `board_solid`
(`src/board.cyr`).

## Scoring (per `src/score.cyr`)

Base values, each × (level + 1):

| clear | regular | mini T-spin | proper T-spin |
|-------|---------|-------------|---------------|
| 0 lines | 0 | 100 | 400 |
| single | 100 | 200 | 800 |
| double | 300 | (400) | 1200 |
| triple | 500 | — | 1600 |
| tetris | 800 | — | — |

- **Back-to-back**: consecutive *difficult* clears (a Tetris, or any
  line-clearing T-spin) add +50% of the base.
- **Combo**: each consecutive line-clearing lock adds 50 × combo × (level+1),
  where combo counts from 0 on the first clear; a clear-less lock breaks it.
- **Drops**: soft drop +1/cell, hard drop +2/cell.
