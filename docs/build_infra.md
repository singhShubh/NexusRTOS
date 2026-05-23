# NexusRTOS Build Infrastructure

This document describes the current build model, module composition, and troubleshooting flow.

Related docs:
- `docs/BOARD_PORTING.md`

## 1. Build system overview

The project uses CMake for a bare-metal cross build.

Core files:
- Root entry: `CMakeLists.txt`
- Toolchain files: `build/cmake/toolchain_<arch>.cmake`
  - current: `toolchain_arm.cmake`, `toolchain_riscv.cmake`
- Board loader helpers: `build/cmake/BoardConfig.cmake`
- Target helper functions: `build/cmake/NexusModule.cmake`
- CLI wrapper: `tools/nx.py`

Final target artifacts:
- `nexus_<board>.elf`
- `nexus_<board>.map`
- `nexus_<board>_secure.bin`
- `nexus_<board>_nonsecure.bin`

Artifact location:
- `build/<board>/<BuildType>/artifacts/`

## 2. Build invariants enforced by CMake

The root build enforces:
1. Out-of-source builds only.
2. Board-specific build directories only (`build/<board>/<BuildType>`).
3. Explicit board selection with `-DNEXUS_BOARD=<board>`.

If `NEXUS_BOARD` is missing or unknown, configure fails with available board names.

## 3. Board selection and derived architecture paths

Board discovery and loading use:
- `bsp_config/<board>/<board>.cmake`

Required board variables:
- `NEXUS_BOARD_ARCH`
- `NEXUS_BOARD_CPU`
- `NEXUS_BOARD_CPU_FLAGS`
- `NEXUS_BOARD_LINKER_SCRIPT`
- `NEXUS_BOARD_INCLUDE_DIRS`

Optional board variable:
- `NEXUS_BOARD_ENABLE_SECURE_WORLD` (`ON`/`OFF`)
  - If omitted, CMake auto-detects secure build enablement from board secure files.

Derived by `nexus_load_board()`:
- `NEXUS_BOARD_ARCH_COMMON_DIR = os/arch/${NEXUS_BOARD_ARCH}/common`
- `NEXUS_BOARD_ARCH_DIR = os/arch/${NEXUS_BOARD_ARCH}/${NEXUS_BOARD_CPU}`
- `NEXUS_BOARD_SECURE_ARCH_DIR = secure/arch/${NEXUS_BOARD_ARCH}/${NEXUS_BOARD_CPU}`
- `NEXUS_BOARD_ARCH_CONFIG = ${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_ARCH_DIR}/arch.cmake`

Path usage:
- Root `CMakeLists.txt` adds `${NEXUS_BOARD_ARCH_COMMON_DIR}` and `${NEXUS_BOARD_ARCH_DIR}`.
- `secure/CMakeLists.txt` adds `${NEXUS_BOARD_SECURE_ARCH_DIR}`.

## 4. Module graph and link model

The root executable links high-level aggregators:
- `nexus_bsp`
- `nexus_drivers`
- `nexus_arch_common`
- `nexus_arch`
- `nexus_boot`
- `nexus_secure`
- `nexus_kernel_impl`
- `nexus_app`

Public-facing dependency targets used by higher layers:
- `nexus_kernel` (app/drivers-facing kernel target)
- `nexus_bsp_public`

Leaf module construction uses:
- `nexus_add_static_module(...)`
- `nexus_add_interface_module(...)`

Both are defined in `build/cmake/NexusModule.cmake`.

## 5. Public vs private header model

Header visibility is controlled through CMake target usage requirements:
- `PUBLIC_INCLUDE_DIRS` for exported API headers.
- `PRIVATE_INCLUDE_DIRS` for module-local headers.
- Project-wide neutral headers: `include/` (via `nexus_common_headers`, linked by `nexus_project_options`).

BSP convention:
- Private board headers: board-local headers under `bsp/<board>/src`
- Shared board config headers: `bsp_config/common/include` (via `NEXUS_BOARD_INCLUDE_DIRS`)
- Board-specific config and public board headers: `bsp_config/<board>` (via `NEXUS_BOARD_INCLUDE_DIRS`)

## 6. Secure vs non-secure source placement

Current source split is mostly directory-based:
- Non-secure/runtime code lives under `os/`, `drivers/`, and `app/`.
- Secure framework code lives under `secure/`.
- Non-secure BSP code lives under `bsp/<board>/`; secure BSP code lives under `secure/bsp/<board>/`.

BSP split:
- `nexus_secure_bsp_<board>` owns secure board sources.
- `nexus_bsp_<board>_nonsecure` owns non-secure board sources.

Boot split:
- Non-secure boot module: `os/boot`
- Secure boot module: `secure/boot`

Architecture split:
- Non-secure arch module: `os/arch/<arch>/<cpu>`
- Secure arch module: `secure/arch/<arch>/<cpu>`

## 7. Linker routing policy

World routing is archive-target driven (not filename-substring driven).

Typical secure archive set:
- `libnexus_secure_boot.a`
- `libnexus_secure_services.a`
- `libnexus_secure_arch_*.a`
- `libnexus_secure_bsp_*.a`

Non-secure output sections are selected with `EXCLUDE_FILE(...)` against the secure archive set.

## 8. Commands

Recommended:

```bash
python3 tools/nx.py list-boards
python3 tools/nx.py build --board mps2_an505 --type debug
python3 tools/nx.py build --board portenta_c33 --type release
python3 tools/nx.py flash-image --board mps2_an505 --type debug
python3 tools/nx.py clean --board mps2_an505 --type debug
python3 tools/nx.py clean --all
```

Equivalent direct CMake flow:

```bash
cmake -S . -B build/mps2_an505/Debug \
  -DCMAKE_TOOLCHAIN_FILE=build/cmake/toolchain_arm.cmake \
  -DNEXUS_BOARD=mps2_an505 \
  -DCMAKE_BUILD_TYPE=Debug

cmake --build build/mps2_an505/Debug -j
```

## 9. Scaffold-mode note

`NEXUS_ENABLE_DUMMY_LINK` (default `ON`) allows generated stub sources so the scaffold remains linkable:
- generator: `build/cmake/NexusDummySources.cmake`

Current entry behavior:
- `mps2_an505`: uses board startup symbol from `secure/bsp/mps2_an505/src/startup.S`.
- `portenta_c33`: currently uses generated `nexus_dummy_entry`.

## 10. Troubleshooting

Configure fails:
1. Run `python3 tools/nx.py list-boards`.
2. Verify `bsp_config/<board>/<board>.cmake` exists and defines required vars.
3. Verify `os/arch/<arch>/<cpu>/arch.cmake` exists for selected board.

Link fails at reset/entry:
1. Check `ENTRY(...)` in `bsp_config/<board>/linker_unified.ld`.
2. Check `secure/bsp/<board>/src/startup.S` symbol names.
3. Check handoff symbol `nexus_boot_reset_entry` in `secure/boot/src/reset_entry.c`.

World placement looks wrong:
1. Check secure archive lists in linker script.
2. Check non-secure `EXCLUDE_FILE(...)` rules.
3. Inspect map file in `build/<board>/<BuildType>/artifacts/`.

IRQ world/priority behavior is wrong:
1. Edit `NEXUS_BOARD_IRQ_TABLE(ENTRY)` in `bsp_config/<board>/interrupt_map.h`.
2. Keep `NEXUS_BOARD_IRQ_COUNT` in `interrupt_map.h` in sync.
3. Rebuild; `bsp/common/src/board_irq_table.c` compiles the shared table from the macro.
