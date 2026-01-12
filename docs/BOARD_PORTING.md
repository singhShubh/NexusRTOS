# Adding a New Board

This document describes what to add when onboarding a new board that uses an already supported architecture/CPU path.

## 1. Directory layout

Create this structure:

```text
bsp/<board>/
├── CMakeLists.txt
├── config/
│   ├── <board>.cmake           # CPU/arch declaration + linker/include path wiring
│   ├── memory_map.h            # manual memory map constants
│   ├── linker_unified.ld       # manual linker script
│   ├── board_irq_map.h         # manual IRQ table declaration + count
│   └── board_irq_table.c       # manual IRQ table definition
├── include/
│   └── board.h                 # re-exports board_irq_map.h
├── inc/
│   └── board_private.h         # private board-internal declarations
├── secure/
│   └── src/
│       ├── board_early_init.c  # consumes nexus_board_irq_table
│       ├── board_boot.c        # optional: board pre-hook implementation
│       └── startup.S           # optional: board-owned reset vector/reset symbol
└── nonsecure/
    └── src/
        └── board_nonsecure.c
```

## 2. Required board config variables

`bsp/<board>/config/<board>.cmake` defines CPU/arch constants, linker script path, and
board include directories:

```cmake
set(NEXUS_BOARD_ARCH "arm")
set(NEXUS_BOARD_CPU "cortex-m33")

set(NEXUS_BOARD_CPU_FLAGS
    -mcpu=cortex-m33
    -mthumb
)

set(NEXUS_BOARD_LINKER_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/linker_unified.ld")

set(NEXUS_BOARD_INCLUDE_DIRS
    ${CMAKE_SOURCE_DIR}/bsp/common/include
    ${CMAKE_SOURCE_DIR}/bsp/<board>/include
    ${CMAKE_CURRENT_LIST_DIR}
)
```

Board hardware data is maintained manually in:

- `bsp/<board>/config/memory_map.h`
- `bsp/<board>/config/linker_unified.ld`
- `bsp/<board>/config/board_irq_map.h`
- `bsp/<board>/config/board_irq_table.c`

Required variables checked by `nexus_load_board()`:

- `NEXUS_BOARD_ARCH`
- `NEXUS_BOARD_CPU`
- `NEXUS_BOARD_LINKER_SCRIPT`
- `NEXUS_BOARD_CPU_FLAGS`
- `NEXUS_BOARD_INCLUDE_DIRS`

Derived by loader:

- `NEXUS_BOARD_ARCH_DIR = arch/${NEXUS_BOARD_ARCH}/${NEXUS_BOARD_CPU}`
- `NEXUS_BOARD_ARCH_CONFIG = ${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_ARCH_DIR}/arch.cmake`

## 3. Board CMakeLists requirements

Your board `CMakeLists.txt` must create:

- `nexus_bsp_public` interface target
- secure board static target
- non-secure board static target
- `nexus_bsp` interface aggregator

Minimal pattern:

```cmake
include(${CMAKE_SOURCE_DIR}/build/cmake/NexusModule.cmake)

nexus_add_interface_module(nexus_bsp_public
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC_DEPS
        nexus_project_options
)

nexus_add_static_module(nexus_bsp_<board>_secure
    SOURCES
        secure/src/board_early_init.c
        config/board_irq_table.c
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/inc
        ${CMAKE_CURRENT_SOURCE_DIR}/secure/src
    PUBLIC_DEPS
        nexus_bsp_public
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_SECURE=1
)

nexus_add_static_module(nexus_bsp_<board>_nonsecure
    SOURCES
        nonsecure/src/board_nonsecure.c
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/inc
        ${CMAKE_CURRENT_SOURCE_DIR}/nonsecure/src
    PUBLIC_DEPS
        nexus_bsp_public
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_NONSECURE=1
)

add_library(nexus_bsp INTERFACE)
target_link_libraries(nexus_bsp INTERFACE
    nexus_bsp_public
    nexus_bsp_<board>_secure
    nexus_bsp_<board>_nonsecure
)
```

Optional board sources can be appended when present, for example:

- `secure/src/board_boot.c`
- other board-specific secure setup files

Private board-only headers should live in `bsp/<board>/inc` and be consumed only through
`PRIVATE_INCLUDE_DIRS` in board implementation targets.

## 4. Startup file behavior

If `bsp/<board>/secure/src/startup.S` exists, it is compiled into `nexus_boot_secure` (not `nexus_bsp_<board>_secure`) through `boot/secure/CMakeLists.txt`.

This is intentional so reset entry and boot handoff symbols stay in the boot link unit flow.

Expected startup behavior:

1. Define secure vector table symbol.
2. Define reset entry symbol.
3. Branch reset entry into `nexus_boot_reset_entry`.

## 5. Manual config artifacts

The following files are maintained directly under each board config directory:

| File | Purpose |
|---|---|
| `memory_map.h` | Board memory region constants consumed by C code |
| `linker_unified.ld` | Board linker script used via `NEXUS_BOARD_LINKER_SCRIPT` |
| `board_irq_map.h` | IRQ table declaration + `NEXUS_BOARD_IRQ_COUNT` |
| `board_irq_table.c` | IRQ descriptors compiled into board secure target |

`board.h` (in `bsp/<board>/include/`) re-exports `board_irq_map.h` as part of the public
board face and is the intended include path for higher layers.

## 6. Linker script requirements

Board linker script should:

1. Define expected stack symbols used by startup.
2. Place secure vector section with `KEEP(...)`.
3. Match entry symbol to the startup symbol name.
4. Route worlds by archive targets, not filename substring matching.

Archive-target routing pattern:

1. Secure output sections include only secure archives, for example:
    - `libnexus_boot_secure.a`
    - `libnexus_security.a`
    - `libnexus_arch_*_secure.a`
    - `libnexus_bsp_*_secure.a`
    - `libnexus_app_secure.a`
2. Non-secure output sections use `EXCLUDE_FILE(...)` with the same secure archive list.

Do not rely on patterns such as `*secure*.obj`; that is fragile and can misroute objects.

## 7. Board discovery

A board is considered discoverable if this file exists:

- `bsp/<board>/config/<board>.cmake`

`tools/nx.py list-boards` and `build/cmake/BoardConfig.cmake` both rely on this naming convention.

## 8. Validation checklist

After adding a board:

```bash
python3 tools/nx.py list-boards
python3 tools/nx.py build --board <board> --type debug
python3 tools/nx.py clean --board <board>
```

Recommended additional check:

```bash
python3 tools/nx.py clean --all
```

## 9. If architecture/CPU path is new

If `arch/<arch>/<cpu>/` does not exist yet, add:

- `arch/<arch>/<cpu>/arch.cmake`
- `arch/<arch>/<cpu>/CMakeLists.txt`
- `secure/` and `nonsecure/` submodule CMake and source skeletons as required

Also ensure the root build includes any required common arch layer for that family. The current root file adds `arch/arm/common` explicitly.
