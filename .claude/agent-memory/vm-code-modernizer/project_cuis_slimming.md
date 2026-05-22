---
name: project-cuis-slimming
description: This opensmalltalk-vm fork is deliberately narrowed to build only Cog Spur 64-bit for 4 targets to serve Cuis; HISTORIC.md documents what was pruned
metadata:
  type: project
---

The repo is a fork of opensmalltalk-vm being narrowed to build ONLY the
production Cog Spur 64-bit VM (`squeak.cog.spur`) for 4 targets: macos64ARMv8,
linux64ARMv8, linux64x64, win64x64. Serves github.com/gstn-caruso/Cuis-Smalltalk-Dev.

**Why:** Cuis only needs this one standard VM; everything else (Pharo, Newspeak,
Sista, Stack-only, V3, spur32, 32-bit, RiscV, Plan9, RiscOS) is dead weight.

**How to apply:** Read `/Users/gaston/Code/opensmalltalk-vm/HISTORIC.md` first —
it is the authoritative map of what existed and what should be removed. Treat
anything it lists as "removed" but still present in git as cleanup debt.

Verified state (2026-05-22): `src/` pruning is DONE (only `spur64.cog` remains).
But `building/` pruning is INCOMPLETE — see [[project-build-system]] for the
specific leftover flavor dirs still tracked in git.

`src/spur64.cog/` is GENERATED C from Slang/VMMaker (VMMaker.oscog-eem.3762).
Do NOT hand-edit it. Shipped binary is at eem-3738; this src is slightly ahead.
`image/` and `processors/` (Bochs/gdb simulators, ~97MB) are KEPT intentionally
because the owner wants VM-regeneration capability.
