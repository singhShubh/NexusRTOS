# NexusRTOS Build Infrastructure

This document explains the current build model, command flows, and board/architecture selection logic.

For board onboarding details, see `docs/BOARD_PORTING.md`.
For boot handoff and early initialization sequence, see `docs/BOOT_FLOW.md`.
For manual BSP config examples, see `docs/CMAKE_CONFIGURE_TUTORIAL.md`.

## 1. Build system overview

The root build is CMake-based and configured as a bare-metal cross build:

- Toolchain file: `build/toolchain.cmake`
- Root entry: `CMakeLists.txt`
- Board loader: `build/cmake/BoardConfig.cmake`
- Helper script: `tools/nx.py`

The final image target is:

- `nexus_<board>.elf`
- map file: `nexus_<board>.map`

Output location:

- `build/<board>/<BuildType>/artifacts/`

## 2. Board selection and derived architecture paths

Board selection is performed with `-DNEXUS_BOARD=<board>`.

The board entry file `bsp/<board>/config/<board>.cmake` defines CPU/arch constants and the
board config paths used by the root build.

Current convention:

- `NEXUS_BOARD_LINKER_SCRIPT` points directly to `bsp/<board>/config/linker_unified.ld`.
- `NEXUS_BOARD_INCLUDE_DIRS` includes board public headers plus `bsp/<board>/config`.
- IRQ policy table source is maintained manually at `bsp/<board>/config/board_irq_table.c`
  and compiled directly by the board secure module.

Variables checked by `nexus_load_board()` after the board file runs:

- `NEXUS_BOARD_ARCH` (example: `arm`)
- `NEXUS_BOARD_CPU` (example: `cortex-m33`)
- `NEXUS_BOARD_CPU_FLAGS`
- `NEXUS_BOARD_LINKER_SCRIPT`
- `NEXUS_BOARD_INCLUDE_DIRS`

From these variables, the loader derives:

- `NEXUS_BOARD_ARCH_DIR = arch/${NEXUS_BOARD_ARCH}/${NEXUS_BOARD_CPU}`
- `NEXUS_BOARD_ARCH_CONFIG = ${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_ARCH_DIR}/arch.cmake`

The root build includes `${NEXUS_BOARD_ARCH_CONFIG}` and adds `${NEXUS_BOARD_ARCH_DIR}` with `add_subdirectory(...)`.

## 3. Module composition and link model

The executable links high-level aggregators rather than every leaf source directly:

- `nexus_bsp`
- `nexus_drivers`
- `nexus_services`
- `nexus_arch_common`
- `nexus_arch`
- `nexus_security`
- `nexus_boot`
- `nexus_kernel_impl`
- `nexus_app`

Leaf modules use `nexus_add_static_module(...)` or `nexus_add_interface_module(...)` from `build/cmake/NexusModule.cmake`.

## 3.1 Public vs private headers

Header visibility is split intentionally:

- Public headers are exported through `PUBLIC_INCLUDE_DIRS` (or interface include dirs) and are part of the module API.
- Private headers are added through `PRIVATE_INCLUDE_DIRS` and are visible only while compiling that module.

Current BSP convention:

- Public board headers: `bsp/<board>/include` (for example `board.h`).
- Private board headers: `bsp/<board>/inc` (for example `board_private.h`).

Typical board module pattern:

```cmake
nexus_add_interface_module(nexus_bsp_public
  PUBLIC_INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

nexus_add_static_module(nexus_bsp_<board>_secure
  SOURCES
    ...
  PRIVATE_INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}/inc
    ${CMAKE_CURRENT_SOURCE_DIR}/secure/src
  PUBLIC_DEPS
    nexus_bsp_public
)
```

Note: board common headers under `bsp/common/include` are injected via
`NEXUS_BOARD_INCLUDE_DIRS` into `nexus_project_options` and therefore become visible to modules that depend on `nexus_project_options`.

## 4. Secure/non-secure linker routing policy

The linker scripts now route secure and non-secure placement by archive target identity, not by source filename text.

Secure sections pull from secure-target archives such as:

- `libnexus_boot_secure.a`
- `libnexus_security.a`
- `libnexus_arch_*_secure.a`
- `libnexus_bsp_*_secure.a`
- `libnexus_app_secure.a`

Non-secure sections include general sections while excluding those secure archives via `EXCLUDE_FILE(...)`.

Why this is used:

1. Avoids false matches from filenames that contain "secure".
2. Keeps world routing aligned with CMake target boundaries.
3. Requires no per-function/per-variable section annotations.

## 5. Build commands

### Recommended helper commands

```bash
python3 tools/nx.py list-boards
python3 tools/nx.py build --board mps2_an505 --type debug
python3 tools/nx.py build --board portenta_c33 --type release
python3 tools/nx.py clean --board mps2_an505 --type debug
python3 tools/nx.py clean --board mps2_an505
python3 tools/nx.py clean --all
```

### Equivalent direct CMake invocation

```bash
cmake -S . -B build/mps2_an505/Debug \
  -DCMAKE_TOOLCHAIN_FILE=build/toolchain.cmake \
  -DNEXUS_BOARD=mps2_an505 \
  -DCMAKE_BUILD_TYPE=Debug

cmake --build build/mps2_an505/Debug -j
```

## 6. Notes on scaffold mode

Most runtime files are still scaffold placeholders. To keep linking possible in this phase, the build can inject dummy generated sources with:

- option: `NEXUS_ENABLE_DUMMY_LINK` (default `ON`)
- generator: `build/cmake/NexusDummySources.cmake`

Current board linker entry behavior in this scaffold:

- `mps2_an505`: linker entry is `reset_handler_s` from `bsp/mps2_an505/secure/src/startup.S`.
- `portenta_c33`: linker entry is `nexus_dummy_entry` while board startup wiring is still being scaffolded.

## 7. Troubleshooting quick checks

If configure fails:

1. Verify board name via `python3 tools/nx.py list-boards`.
2. Verify `bsp/<board>/config/<board>.cmake` sets `NEXUS_BOARD_LINKER_SCRIPT`.
3. Verify `bsp/<board>/config/<board>.cmake` sets `NEXUS_BOARD_INCLUDE_DIRS` and includes `bsp/<board>/config`.
4. Verify derived path `arch/<arch>/<cpu>/arch.cmake` exists.

If link fails with reset/entry symbols:

1. Check linker script `ENTRY(...)` in `bsp/<board>/config/linker_unified.ld`.
2. Check board startup symbol definitions in `bsp/<board>/secure/src/startup.S`.
3. Check boot handoff symbol `nexus_boot_reset_entry` is reachable from boot secure target.

If secure/non-secure placement is wrong:

1. Check secure archive selectors in `bsp/<board>/config/linker_unified.ld`.
2. Check `EXCLUDE_FILE(...)` list for non-secure sections matches secure archives.
3. Confirm map file placement in `build/<board>/<BuildType>/artifacts/nexus_<board>.map`.

If an IRQ is routing to the wrong world:

1. Edit the relevant entry in `bsp/<board>/config/board_irq_table.c`.
2. Verify the count in `bsp/<board>/config/board_irq_map.h` still matches table length.
3. Rebuild and confirm expected behavior.
