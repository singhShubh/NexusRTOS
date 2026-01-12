# Directory Tree (Dependency-Hardened Version)

```text
NexusRTOS/
├── CMakeLists.txt
├── README.md
├── build/
│   ├── toolchain.cmake
│   └── cmake/
│       ├── BoardConfig.cmake
│       ├── NexusCommon.cmake
│       ├── NexusDummySources.cmake
│       └── NexusModule.cmake
├── docs/
│   ├── BOARD_PORTING.md
│   ├── BOOT_FLOW.md
│   ├── CMAKE_CONFIGURE_TUTORIAL.md
│   ├── DEPENDENCY_MODEL.md
│   ├── DIRECTORY_TREE.md
│   ├── TODO.md
│   └── build_infra.md
├── include/
│   └── nexus_config.h
├── app/
├── arch/
├── boot/
├── bsp/
│   ├── common/
│   │   └── include/
│   │       └── board_common.h          # nexus_irq_desc_t, nexus_irq_domain_t
│   └── <board>/
│       ├── CMakeLists.txt
│       ├── config/
│       │   ├── <board>.cmake           # CPU flags + linker/include path wiring
│       │   ├── memory_map.h            # manual board memory constants
│       │   ├── linker_unified.ld       # manual board linker script
│       │   ├── board_irq_map.h         # manual IRQ table declaration + count
│       │   └── board_irq_table.c       # manual IRQ table definition
│       ├── inc/
│       │   └── board_private.h         # private board-only declarations
│       └── include/
│           └── board.h                 # public board face; re-exports board_irq_map.h
├── drivers/
├── kernel/
│   ├── api/
│   ├── internal/
│   ├── core/
│   ├── sched/
│   ├── task/
│   ├── irq/
│   ├── mem/
│   ├── ipc/
│   ├── subsys/
│   └── syscall/
├── security/
├── services/
└── tools/
```
