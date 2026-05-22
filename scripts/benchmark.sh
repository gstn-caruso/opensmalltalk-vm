#!/usr/bin/env bash
# benchmark.sh — run the Smalltalk VM benchmark with a given image.
#
# Usage:
#   ./scripts/benchmark.sh <vm-binary> <image-path> [label]
#
# On macOS with an .app bundle:
#   ./scripts/benchmark.sh products/SqueakFast.app/Contents/MacOS/Squeak image.image standard
#
# The benchmark script (benchmark.st) is expected alongside this file.

set -euo pipefail

VM="${1:-}"
IMAGE="${2:-}"
LABEL="${3:-benchmark}"
SCRIPT="$(cd "$(dirname "$0")" && pwd)/benchmark.st"

usage() {
    echo "Usage: $0 <vm-binary> <image-path> [label]"
    echo "  vm-binary   path to the Squeak/Cuis VM executable"
    echo "  image-path  path to a .image file"
    echo "  label       optional label for the output (default: benchmark)"
    exit 1
}

[[ -z "$VM" ]]    && usage
[[ -z "$IMAGE" ]] && usage
[[ ! -x "$VM" ]]  && { echo "ERROR: VM not executable: $VM"; exit 1; }
[[ ! -f "$IMAGE" ]] && { echo "ERROR: image not found: $IMAGE"; exit 1; }
[[ ! -f "$SCRIPT" ]] && { echo "ERROR: benchmark.st not found at $SCRIPT"; exit 1; }

echo "=== VM Benchmark: $LABEL ==="
echo "vm:    $VM"
echo "image: $IMAGE"
echo ""

WALL_START=$(date +%s%3N 2>/dev/null || python3 -c "import time; print(int(time.time()*1000))")

"$VM" "$IMAGE" "$SCRIPT" 2>&1

WALL_END=$(date +%s%3N 2>/dev/null || python3 -c "import time; print(int(time.time()*1000))")
echo "total_wall_ms=$((WALL_END - WALL_START))"
echo "=== end: $LABEL ==="
