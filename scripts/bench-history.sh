#!/bin/sh
# Record cyrius-polyomino benchmark results to a CSV trail for tracking
# over time. Dual output: appends a CSV row + prints a human summary.
# Usage: sh scripts/bench-history.sh
set -e

CSV="bench-history.csv"
BENCH_SRC="benches/polyomino.bcyr"
BENCH_BIN="build/bench_polyomino"
GAME_BIN="build/cyrius-polyomino"

# Build the benchmark binary (and a DCE game binary for the size metric).
mkdir -p build
cyrius build "$BENCH_SRC" "$BENCH_BIN" > /dev/null
CYRIUS_DCE=1 cyrius build src/main.cyr "$GAME_BIN" > /dev/null

# Run benchmarks, capture output.
OUTPUT=$("$BENCH_BIN" 2>&1)

VERSION=$(cat VERSION | tr -d '[:space:]')
DATE=$(date +%Y-%m-%d)
BINARY_SIZE=$(wc -c < "$GAME_BIN" 2>/dev/null || echo 0)

# "  name: <avg> avg (min=..." -> "<avg>"
extract_avg() { echo "$OUTPUT" | grep "  $1:" | sed 's/.*: \([^ ]*\) avg.*/\1/'; }
piece_word=$(extract_avg "piece_word")
collides=$(extract_avg "board_collides")
clear_lines=$(extract_avg "board_clear_lines")
render=$(extract_avg "render_world")

if [ ! -f "$CSV" ]; then
    echo "date,version,binary_bytes,piece_word,board_collides,board_clear_lines,render_world" > "$CSV"
fi
echo "$DATE,$VERSION,$BINARY_SIZE,$piece_word,$collides,$clear_lines,$render" >> "$CSV"

echo "=== Recorded to $CSV ==="
echo "  version:           $VERSION"
echo "  binary:            $BINARY_SIZE bytes"
echo "  piece_word:        $piece_word"
echo "  board_collides:    $collides"
echo "  board_clear_lines: $clear_lines"
echo "  render_world:      $render"
