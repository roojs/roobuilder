#!/bin/bash -x

# Point at repos via the manifest; write BJS→VBP→BJS under build/vbp-roundtrip; diff.
# Usage: ./test_vbp_roundtrip.sh [manifest] [output_dir]
# Manifest lines: project_path|all  or  project_path|relpath.bjs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN="$ROOT/build/roobuilder"
MANIFEST="${1:-$SCRIPT_DIR/vbp-roundtrip.manifest}"
OUT="${2:-$ROOT/build/vbp-roundtrip}"

if [[ ! -x "$BIN" ]]; then
	echo "ERROR: $BIN not found — ninja -C build"
	exit 1
fi
if [[ ! -f "$MANIFEST" ]]; then
	echo "ERROR: manifest not found: $MANIFEST"
	exit 1
fi

mkdir -p "$OUT"
echo "=== VBP round-trip ==="
echo "manifest: $MANIFEST"
echo "output:   $OUT"

while IFS= read -r line || [[ -n "$line" ]]; do
	row="${line%%#*}"
	row="$(echo "$row" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
	[[ -z "$row" ]] && continue
	project="${row%%|*}"
	spec="${row#*|}"
	"$BIN" --project "$project" --test-vbp-roundtrip "$spec" --vbp-roundtrip-dir "$OUT"
done < "$MANIFEST"

fail=0
while IFS= read -r orig; do
	rt="${orig%.original.bjs}.roundtrip.bjs"
	echo "=== diff $orig ==="
	if ! diff -u "$orig" "$rt"; then
		fail=1
	fi
done < <(find "$OUT" -name '*.original.bjs' | sort)

exit "$fail"
