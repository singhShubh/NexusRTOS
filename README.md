# NexusRTOS Dependency-Hardened Scaffold

This scaffold demonstrates a **dependency-hardened** modular build for NexusRTOS.

Current status: scaffold mode with placeholder implementations in many runtime modules.

## What this repository is

NexusRTOS is organized as a layered embedded codebase where CMake target dependencies enforce architectural boundaries.

## Core idea

The codebase is not only split into neat directories — the **CMake target graph enforces layering**.

### External-facing layers
- `os/kernel/`                    → public kernel target (`nexus_kernel`) visible to drivers and applications
- `drivers/*/include`    → public driver APIs visible to applications
- `bsp/<board>/include`  → public board constants visible to low-level layers that need them

### Internal-only layers
- `os/kernel/internal/`  → kernel-private interfaces visible only to kernel implementation modules
- `os/arch/*`            → non-secure architecture implementation details
- `secure/arch/*`  → secure architecture implementation details
- `secure/`        → secure implementation modules
- `os/boot/*`            → non-secure/runtime boot stubs
- `secure/boot/*`  → secure reset and boot orchestration

## Dependency-hardening rules in this scaffold

- `drivers/*` depend only on:
  - `nexus_kernel`
  - `nexus_bsp_public`
- `os/kernel/*` implementation modules depend on:
  - `nexus_kernel_internal_api`
  - other kernel implementation modules where needed
- `app` depends only on:
  - `nexus_kernel`
- `app/*` does **not** get access to `os/kernel/internal/include`.

## Build outputs

- Unified ELF: `nexus_<board>.elf`
- Secure BIN: `nexus_<board>_secure.bin`
- Non-secure BIN: `nexus_<board>_nonsecure.bin`
- Linker MAP: `nexus_<board>.map`
- All build artifacts stay under `build/<board>/<BuildType>/`
- The supported build flow keeps CMake-generated state under `build/<board>/<BuildType>/`

Build infrastructure sources live in `build/cmake/` (toolchain, board loader, module helpers).

## Quick start

```bash
python3 tools/nx.py list-boards
python3 tools/nx.py build --board mps2_an505 --type debug
python3 tools/nx.py flash-image --board mps2_an505 --type debug
python3 tools/nx.py clean --board mps2_an505 --type debug
python3 tools/nx.py clean --all
```

## Documentation index

- Build infrastructure and commands: [docs/build_infra.md](docs/build_infra.md)
- Adding a new board: [docs/BOARD_PORTING.md](docs/BOARD_PORTING.md)

## Placeholder note

Many checked-in runtime files are still scaffold placeholders.
To keep the scaffold linkable while implementation is in progress, the build system generates tiny stub sources
**inside the build directory only**.
