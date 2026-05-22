#!/usr/bin/env bash
# local-benchmark-macos.sh — builds two VMs and compares them on your machine.
#
# Usage:
#   ./scripts/local-benchmark-macos.sh <path-to-image.image>
#
# Requirements:
#   - Xcode command line tools (xcode-select --install)
#   - A Cuis or Squeak .image file
#
# What it does:
#   1. Builds a standard VM  (CONFIGURATION=product, -Os)
#   2. Builds a native VM    (CONFIGURATION=native,  -O3 -mcpu=native)
#   3. Runs benchmark.st on both and prints a side-by-side comparison.

set -euo pipefail

IMAGE="${1:-}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$REPO_ROOT/building/macos64ARMv8/squeak.cog.spur"
BENCH_ST="$REPO_ROOT/scripts/benchmark.st"

usage() {
    echo "Usage: $0 <path-to-image.image>"
    echo ""
    echo "Example:"
    echo "  $0 ~/Cuis-Smalltalk-Dev/Cuis6.3-6543.image"
    exit 1
}

[[ -z "$IMAGE" ]] && usage
[[ ! -f "$IMAGE" ]] && { echo "ERROR: image not found: $IMAGE"; exit 1; }

# ── Build both VMs ──────────────────────────────────────────────────────────

echo "==> Building standard VM (-Os) ..."
(cd "$BUILD_DIR" && bash ./mvm -f 2>&1) | tail -5
STANDARD_APP=$(find "$BUILD_DIR" -maxdepth 1 -name "SqueakFast.app" | head -1)
[[ -z "$STANDARD_APP" ]] && { echo "ERROR: standard build not found in $BUILD_DIR"; exit 1; }
VM_STANDARD="$STANDARD_APP/Contents/MacOS/Squeak"

echo ""
echo "==> Building native VM (-O3 -mcpu=native) ..."
(cd "$BUILD_DIR" && bash ./mvm -n 2>&1) | tail -5
NATIVE_APP=$(find "$BUILD_DIR" -maxdepth 1 -name "SqueakFastNative.app" | head -1)
[[ -z "$NATIVE_APP" ]] && { echo "ERROR: native build not found in $BUILD_DIR"; exit 1; }
VM_NATIVE="$NATIVE_APP/Contents/MacOS/Squeak"

# ── Run benchmarks ──────────────────────────────────────────────────────────

echo ""
echo "==> Running benchmarks ..."
echo ""

"$VM_STANDARD" "$IMAGE" "$BENCH_ST" 2>&1 | tee /tmp/bench_standard.txt
echo ""
"$VM_NATIVE"   "$IMAGE" "$BENCH_ST" 2>&1 | tee /tmp/bench_native.txt

# ── Compare results ─────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════════"
echo "  Benchmark comparison  (Apple M-series, -mcpu=native)"
echo "════════════════════════════════════════════════════════"
printf "%-30s %12s %12s %10s\n" "Benchmark" "Standard(ms)" "Native(ms)" "Speedup"
printf "%-30s %12s %12s %10s\n" "─────────────────────────────" "────────────" "──────────" "────────"

python3 - <<'EOF'
import re

def parse(path):
    results = {}
    with open(path) as f:
        for line in f:
            m = re.match(r'^(\w+)=(\d+)', line.strip())
            if m:
                results[m.group(1)] = int(m.group(2))
    return results

std = parse('/tmp/bench_standard.txt')
nat = parse('/tmp/bench_native.txt')

for key in std:
    sv = std[key]
    nv = nat.get(key, 0)
    if sv > 0 and nv > 0:
        speedup = sv / nv
        arrow = "▲" if speedup >= 1.05 else ("▼" if speedup < 0.98 else "=")
        print(f"{key:<30} {sv:>12} {nv:>12}  {arrow} {speedup:.2f}x")
    else:
        print(f"{key:<30} {sv:>12} {'n/a':>12}  {'?':>10}")
EOF

echo "════════════════════════════════════════════════════════"
echo ""
echo "Builds:"
echo "  Standard: $STANDARD_APP"
echo "  Native:   $NATIVE_APP"
