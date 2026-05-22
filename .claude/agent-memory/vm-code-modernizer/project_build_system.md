---
name: project-build-system
description: The real build path is per-platform mvm Makefiles driven by scripts/ci/actions_build.sh; the top-level CMakeLists.txt is unused legacy
metadata:
  type: project
---

The production build uses per-platform Makefile-based scripts under
`building/<target>/squeak.cog.spur/` invoked via `mvm`, orchestrated by
`scripts/ci/actions_build.sh` (Linux: `make configure` then mvm; mac/win: mvm).

**Why:** This is what GitHub Actions workflows (.github/workflows/*.yml) actually
run. The top-level `CMakeLists.txt` (25KB) + `cmake/` (29 files) are an alternate
build system that NO CI workflow or script references — confirmed unused.

**How to apply:** When auditing build, trust the Makefile path. Flag CMake as
dead-code candidate but confirm with owner before deleting (HISTORIC.md §8 also
flags this as "decide before deleting"). CMake still mentions removed flavors
(stack/minheadless suffixes, lines ~150-160) so it's also stale.

Real-build C standard: only `-std=c++14` set for C++; C uses compiler default.
CMake (unused) sets `-std=gnu99`. So C-standard modernization touches the Makefile
build, not CMake, to have any effect.

INCOMPLETE building/ cleanup still tracked in git (HISTORIC says removed):
`building/{linux64x64,win64x64}/squeak.sista.spur`, `.../squeak.stack.spur`,
`.../bochsx64`, `.../bochsx86`, `.../gdbarm32`, `.../gdbarm64`.
