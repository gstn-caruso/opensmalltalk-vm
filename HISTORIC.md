# HISTORIC.md — Knowledge preserved before the Cuis-only slimming

This fork of `opensmalltalk-vm` is being narrowed to build **only** the
production **Cog Spur 64-bit VM** (`squeak.cog.spur`) for **four** targets,
which are exactly the platforms needed to run Cuis and its CI tests:

- macOS arm64 (`building/macos64ARMv8`) — arm only, NOT universal
- Linux arm64 (`building/linux64ARMv8`)
- Linux x86-64 (`building/linux64x64`)
- Windows x86-64 (`building/win64x64`)

These map to the slots of the Cuis `CuisVM.app` bundle (Contents/MacOS,
Linux-arm64, Linux-x86_64, Windows-x86_64) consumed by
github.com/gstn-caruso/Cuis-Smalltalk-Dev. Windows-arm64 and macOS x86_64 are
intentionally NOT built.

Cuis Smalltalk runs on this standard 64-bit Spur Cog VM. Everything documented
below is being removed or archived. This file records *what existed and why*, so
no knowledge is lost.

**Reference VM (the one actually used):** `CuisVM.app` reports
`[Production Spur 64-bit VM]`, `CoInterpreter VMMaker.oscog-eem.3738`, build
`202603271636`, a **universal** (x86_64 + arm64) Mach-O. This fork's `src/` is at
`VMMaker.oscog-eem.3762` — i.e. slightly ahead of the shipped binary. Shipped
plugins to preserve: B3DAccelerator, Camera, ClipboardExtended, Croquet, DES,
MD5, Mpeg3, SHA2, Squeak3D, SqueakFFIPrims, SqueakSSL, UnixOSProcess,
VectorEngine.

---

## 1. How the VM is actually built (essential mental model)

- The VM is **written in Smalltalk** ("Slang") and **transpiled to C** using the
  VMMaker tool inside a Squeak/Cuis image. The generated C lives versioned under
  `src/`. You normally **do not edit `src/` by hand**.
- To merely *compile* the VM you only need: the generated C in `src/spur64.cog`,
  the platform glue under `platforms/`, and the per-platform build scripts under
  `building/<target>/squeak.cog.spur`.
- To *regenerate / modify* the VM (change the interpreter or JIT) you additionally
  need the developer tooling: `image/` (bootstrap a VMMaker image) and
  `processors/` (Bochs/gdb CPU simulators used to test JIT code). The owner wants
  to keep this capability, so **`image/` and `processors/` are KEPT.**

## 2. `src/` variants (only `spur64.cog` is kept)

| dir | what it is | kept? |
|-----|------------|-------|
| `spur64.cog` | 64-bit Spur object format, Cog JIT — **the production VM** | KEEP |
| `spur32.*` | 32-bit object memory variants | removed |
| `*.sista` | Sista adaptive-optimizing experimental VM | removed |
| `*.lowcode` | Lowcode FFI experimental bytecode set | removed |
| `*.stack` | StackInterpreter (no JIT) — slower reference VM | removed |
| `v3.*` | pre-Spur (v3) object format — legacy | removed |

`src/spur64.cog` contains: `cointerp.c`, `cogit.c`, `cogitARMv8.c`,
`cogitX64SysV.c` (mac/linux), `cogitX64WIN64.c` (windows).

## 3. Platform trees

| dir | role | kept? |
|-----|------|-------|
| `platforms/Cross` | shared cross-platform VM core + plugins (used by ALL builds) | KEEP |
| `platforms/iOS/vm/OSX`, `.../Common`, `platforms/iOS/plugins` | **macOS** VM sources (mac shares the iOS tree) | KEEP |
| `platforms/iOS/vm/iPhone` | iOS device-only code | removable |
| `platforms/unix` | Linux build (configure + vm sources) | KEEP |
| `platforms/win32` | Windows build (MinGW makefiles + vm sources) | KEEP |
| `platforms/Plan9` | Plan 9 OS port (legacy `mkfile` build) | removed |
| `platforms/RiscOS` | RISC OS port (legacy) | removed |
| `platforms/minheadless` | cmake-based headless build template | removed (verify) |

## 4. Dropped build targets (`building/`)

Kept: `macos64ARMv8`, `linux64ARMv8`, `linux64x64`, `win64x64`.
Removed: `linux32`, `linux32ARMv6`, `linux32ARMv7`, `linux32x86`, `linux64`,
`linux64riscv`, `macos32x86`, `macos64x64` (Intel mac — not used),
`win32x86`, `win64ARMv8`, `sunos32x86`, `sunos64x64`, `minheadless.cmake`.
Inside each kept target, removed: `squeak.sista.spur`, `squeak.stack.spur`,
`bochsx64`, `bochsx86`, `gdbarm32`, `gdbarm64`, `makesista`.

## 5. Deprecated VM flavors (already dropped upstream, Aug 2025)

- **Pharo VM** — last sources at git tag `last-support-pharo`.
- **Newspeak VM** — last sources at git tag `last-support-newspeak`.

## 6. Branches (consolidating to a single `main`)

`origin/Cog` was the **active** development branch (recent VMMaker.oscog-eem.3762)
and becomes `main`. `origin/master` was stale (~6–7 years old). The ~40 remote
branches fall into:

- **Active/legacy core:** `Cog` (active), `oldTrunk`, `master` (stale).
- **Experimental VMs:** `CogMT` (multithreaded), `eliot`, `monty`,
  `mtffiexperiments`, `experimental_FFI`, `newspeak-bootstrap`, `pharo/headless`.
- **Contributor branches:** `JMM/*` (iOS, ARM, sleep/window fixes),
  `dtl/*` (Linux aio/epoll/fork tweaks), `fniephaus/*` (CI/debug),
  `krono/*` (Raspberry Pi aarch64, Win32), `marceltaeumel/WinSDK`,
  `estebanlm/fix-pharo-upload`.
- **Platform/plugin/fix branches:** `platform/Cross/plugins`,
  `platform/win32/plugins`, `add-VectorEnginePlugin`, `Fix_GDI_leak`,
  `MSVCCodeGenerationBug`, `compile_legacy_Mac_OS`, `virtend`.

The full upstream history (and these branches) remains recoverable from the
upstream remote and from the safety tag/bundle created in Phase 0 of the migration.

## 7. Developer-only / release infrastructure

KEPT (owner wants to keep VM-regeneration capability):
- `processors/` (~97 MB) — Bochs x86/x64 + gdb ARM CPU simulators, used to test
  JIT codegen in the VMMaker simulator. Needed to *regenerate* the VM.
- `image/` — shell + `.st` scripts to bootstrap/update a VMMaker Squeak image.

Removed:
- `specs/lowcode.xml` — Sista lowcode config.
- `scripts/mk*vmarchives`, SVN-era maintenance scripts — release/packaging.
- `deploy/` — VM packaging/signing wrappers (keep if you still cut releases).

## 8. Build-system note (decide before deleting)

The active per-platform builds live under `building/<target>/squeak.cog.spur`
(Makefiles for mac/win; `platforms/unix/config/configure` for Linux). The
top-level `CMakeLists.txt` + `cmake/` appear to be an alternate/legacy build
system. Confirm which one you actually use before deleting either.
