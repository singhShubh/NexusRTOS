# Adding a New Board

This document describes how to onboard a board using the split between declarative board configuration, non-secure BSP code, and secure BSP code.

## 1. Required directory layout

Create shared board configuration headers under `bsp_config/common/include/`, board description files under `bsp_config/<board>/`, non-secure board code under `bsp/<board>/`, and secure board code under `secure/bsp/<board>/`:

```text
bsp_config/common/include/
└── board_common.h

bsp_config/<board>/
├── <board>.cmake
├── memory_map.h
├── linker_unified.ld
└── interrupt_map.h

bsp/<board>/
├── CMakeLists.txt
└── src/
    └── board_nonsecure.c

secure/bsp/<board>/
├── CMakeLists.txt
└── src/
    ├── board_early_init.c
    ├── board_boot.c      # optional
    └── startup.S         # optional secure startup source
```

Notes:
- `bsp_config/common/include` contains shared board configuration headers consumed by both `bsp/` and `secure/bsp/` through `NEXUS_BOARD_INCLUDE_DIRS`.
- `bsp_config/<board>` contains board description/static hardware facts.
- `bsp/<board>` contains board-specific non-secure implementation code.
- `secure/bsp/<board>` contains board-specific secure implementation code.

## 2. Board config file requirements

`bsp_config/<board>/<board>.cmake` must define:

```cmake
set(NEXUS_BOARD_ARCH "arm")
set(NEXUS_BOARD_CPU "cortex-m33")
set(NEXUS_BOARD_ENABLE_SECURE_WORLD ON)  # optional (ON/OFF). If omitted, auto-detected.

set(NEXUS_BOARD_CPU_FLAGS
    -mcpu=cortex-m33
    -mthumb
)

set(NEXUS_BOARD_LINKER_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/linker_unified.ld")

set(NEXUS_BOARD_INCLUDE_DIRS
    ${CMAKE_SOURCE_DIR}/bsp_config/common/include
    ${CMAKE_SOURCE_DIR}/bsp_config/<board>
)
```

Required variables checked by `nexus_load_board()`:
- `NEXUS_BOARD_ARCH`
- `NEXUS_BOARD_CPU`
- `NEXUS_BOARD_LINKER_SCRIPT`
- `NEXUS_BOARD_CPU_FLAGS`
- `NEXUS_BOARD_INCLUDE_DIRS`

Optional variable:
- `NEXUS_BOARD_ENABLE_SECURE_WORLD`

Derived by loader:
- `NEXUS_BOARD_ARCH_COMMON_DIR = os/arch/${NEXUS_BOARD_ARCH}/common`
- `NEXUS_BOARD_ARCH_DIR = os/arch/${NEXUS_BOARD_ARCH}/${NEXUS_BOARD_CPU}`
- `NEXUS_BOARD_SECURE_ARCH_DIR = secure/arch/${NEXUS_BOARD_ARCH}/${NEXUS_BOARD_CPU}`
- `NEXUS_BOARD_ARCH_CONFIG = ${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_ARCH_DIR}/arch.cmake`

## 3. BSP CMake target pattern

`bsp/<board>/CMakeLists.txt` must define:
- `nexus_bsp_public` (interface module)
- `nexus_bsp_<board>_nonsecure` (static module)
- `nexus_bsp` (interface aggregator)

`secure/bsp/<board>/CMakeLists.txt` must define:
- `nexus_secure_bsp_<board>` (static module)
- `nexus_secure_bsp` (interface aggregator)

The secure BSP target should compile `${CMAKE_SOURCE_DIR}/bsp/common/src/board_irq_table.c` if the board uses the common IRQ table generated from `interrupt_map.h`.

## 4. Startup file behavior

If `secure/bsp/<board>/src/startup.S` exists, `secure/boot/CMakeLists.txt` automatically appends it to `nexus_secure_boot`.

Expected startup behavior:
1. Define secure vector table symbol(s).
2. Define reset entry symbol, for example `reset_handler_s`.
3. Branch reset entry to `nexus_boot_reset_entry`.

## 5. Manual board artifacts

Maintain these files directly under `bsp_config/<board>/`:
- `memory_map.h`
- `linker_unified.ld`
- `interrupt_map.h`

`interrupt_map.h` should define `NEXUS_BOARD_IRQ_TABLE(ENTRY)`, `NEXUS_BOARD_IRQ_COUNT`, and the `nexus_board_irq_table` declaration. The common source `bsp/common/src/board_irq_table.c` expands that macro into the compiled IRQ descriptor table.

## 6. Linker script requirements

Board linker scripts should:
1. Define expected stack symbols.
2. Place secure vector section with `KEEP(...)`.
3. Match `ENTRY(...)` to your startup symbol.
4. Route secure/non-secure content by archive identity.

Secure archive examples:
- `libnexus_secure_boot.a`
- `libnexus_secure_services.a`
- `libnexus_secure_arch_*.a`
- `libnexus_secure_bsp_*.a`

## 7. Board discovery rule

A board is discoverable when this file exists:
- `bsp_config/<board>/<board>.cmake`

Both `tools/nx.py list-boards` and `build/cmake/BoardConfig.cmake` rely on this convention.

## 8. Validation checklist

```bash
python3 tools/nx.py list-boards
python3 tools/nx.py build --board <board> --type debug
python3 tools/nx.py build --board <board> --type release
python3 tools/nx.py clean --board <board>
python3 tools/nx.py clean --all
```

## 9. When architecture/CPU path is new

If `os/arch/<arch>/<cpu>/` does not exist, add:
- `os/arch/<arch>/<cpu>/arch.cmake`
- `os/arch/<arch>/<cpu>/CMakeLists.txt`
- `os/arch/<arch>/<cpu>/include/*`
- `os/arch/<arch>/<cpu>/src/*`

If secure-side arch hooks are needed, also add:
- `secure/arch/<arch>/<cpu>/CMakeLists.txt`
- `secure/arch/<arch>/<cpu>/include/*`
- `secure/arch/<arch>/<cpu>/src/*`
