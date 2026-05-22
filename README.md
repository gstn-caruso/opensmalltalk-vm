# Cuis VM (fork reducido de OpenSmalltalk)

Este es un fork **reducido** de [OpenSmalltalk-VM](https://github.com/OpenSmalltalk/opensmalltalk-vm),
recortado para hacer **una sola cosa bien**: compilar la máquina virtual que
usa **[Cuis Smalltalk](https://cuis.st)** en las plataformas que realmente
necesito, y generar artefactos listos para correr los tests de
[gstn-caruso/Cuis-Smalltalk-Dev](https://github.com/gstn-caruso/Cuis-Smalltalk-Dev).

El OpenSmalltalk-VM original soporta decenas de variantes de VM y de sistemas
operativos. Acá se eliminó todo eso. Si necesitás el VM completo, andá al repo
original. Lo que se removió y por qué está documentado en
[`HISTORIC.md`](HISTORIC.md).

---

## Qué VM compila este repo

Una única variante: **`squeak.cog.spur`** — la VM de producción de 64 bits, con:

- **Spur**: el formato moderno de objetos en memoria (generation scavenging,
  forwarding perezoso, mismo header en 32/64 bits).
- **Cog**: el JIT (`StackToRegisterMappingCogit`) que compila a código máquina
  los métodos usados más de una vez.

No es "Cog **o** Spur": es una sola VM que es **Spur + Cog** a la vez. Se
eliminaron las demás combinaciones (Sista, Stack, v3, lowcode, multi-thread).

## Plataformas (4 targets)

| Slot en `CuisVM.app` | Target de build (`building/`) |
|----------------------|-------------------------------|
| `MacOS` (solo arm64) | `macos64ARMv8`                |
| `Linux-arm64`        | `linux64ARMv8`                |
| `Linux-x86_64`       | `linux64x64`                  |
| `Windows-x86_64`     | `win64x64`                    |

No se compila: macOS Intel, Windows arm64, ningún 32 bits, ni RISC-V/SunOS/etc.

## De dónde sale la versión

La versión (ej. `202605220725`, formato `AAAAMMDDHHMM`) se genera a partir de
git con:

```sh
./scripts/updateSCCSVersions
```

Ese script escribe `platforms/Cross/vm/sqSCCSVersion.h` (campo
`SvnRawRevisionString`) e instala hooks de git para mantenerlo al día. **Hay que
correrlo una vez después de clonar**, o el build se detiene pidiéndolo. El CI usa
esa misma cadena como nombre de los artefactos (`ASSET_REVISION`).

---

## Compilar localmente

### Requisitos

- **macOS arm64**: Xcode + clang. Si `ibtool` falla al compilar el `.nib`, corré
  una vez `sudo xcodebuild -runFirstLaunch`.
- **Linux**: `gcc`, `make`, y las libs de desarrollo (ver
  `scripts/ci/actions_prepare_linux_x86.sh` / `_arm.sh`).
- **Windows**: MSYS2 (`scripts/installMSYS2.cmd`).

### Pasos

```sh
# 1. Una sola vez tras clonar: estampar la versión
./scripts/updateSCCSVersions

# 2. Ir al target de tu plataforma y compilar la VM de producción
cd building/macos64ARMv8/squeak.cog.spur   # o linux64x64, linux64ARMv8, win64x64
./mvm -f
```

En macOS el resultado es `Squeak.app`. En Linux/Windows el ejecutable y sus
plugins quedan bajo `build/`. Ver `building/<target>/HowToBuild` para detalle.

---

## Estructura del repo

```
src/spur64.cog/       C generado por VMMaker (la VM). NO se edita a mano.
src/plugins/          Fuentes C de los plugins.
building/<target>/    Scripts de build por plataforma (Makefiles / configure).
platforms/Cross/      Código de VM y plugins común a todas las plataformas.
platforms/iOS/        Fuentes del VM de macOS (mac comparte el árbol iOS).
platforms/unix/       Build de Linux.
platforms/win32/      Build de Windows.
scripts/ci/           Scripts que usa GitHub Actions.
deploy/               Empaquetado de la VM.
.github/workflows/    CI (ver abajo).
HISTORIC.md           Qué se eliminó del fork original y por qué.
```

> La VM se escribe en Smalltalk ("Slang") y se transpila a C con VMMaker dentro
> de una imagen. El C versionado en `src/` es ese resultado. Para *modificar* la
> VM se necesita el entorno VMMaker, que **no** está incluido en este fork
> reducido (sí está en el original).

---

## Integración continua (GitHub Actions)

Una sola rama: **`main`**.

- **En cada Pull Request a `main`** corren los 4 workflows de build como
  *chequeos*: si las 4 plataformas compilan `squeak.cog.spur`, el check pasa.
  - `.github/workflows/macos-arm.yml` — macOS arm64
  - `.github/workflows/linux.yml` — Linux x86-64
  - `.github/workflows/linux-arm64.yml` — Linux arm64
  - `.github/workflows/win.yml` — Windows x86-64

- **Al mergear/pushear a `main`** se compilan las 4 plataformas y se publican los
  binarios como release, listos para que `Cuis-Smalltalk-Dev` los consuma
  ensamblados en un `CuisVM.app` (slots `MacOS`, `Linux-arm64`, `Linux-x86_64`,
  `Windows-x86_64`).

---

## Respaldo de la historia

Este fork **reinició su historia git** para quedar liviano. La historia
completa anterior (todas las ramas y tags del fork original) está preservada en
un *bundle* de git fuera del repo y sigue disponible en el OpenSmalltalk-VM
original. Ver [`HISTORIC.md`](HISTORIC.md).

## Licencia

MIT, igual que OpenSmalltalk-VM. Ver [`LICENSE`](LICENSE).
