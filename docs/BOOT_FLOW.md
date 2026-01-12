# Generic Boot Flow (BSP Reset Entry to Kernel Init)

This document captures the current generic secure boot sequence and ownership boundaries in NexusRTOS.

## 1. Ownership model

- BSP owns board reset entry point and board-specific early hooks.
- Boot owns sequencing and handoff orchestration.
- Arch owns CPU/exception/protection setup hooks.
- Security owns secure service setup hook.
- Kernel owns runtime initialization entry.

## 2. Calling sequence

Current secure boot sequence for boards that provide `startup.S` (for example `mps2_an505`):

1. `reset_handler_s`
2. `nexus_boot_reset_entry`
3. `nexus_boot_init`
4. `nexus_board_early_init`
5. `nexus_arch_exception_init`
6. `nexus_arch_interrupt_target_init`
7. `nexus_arch_protection_init`
8. `nexus_security_services_init`
9. `nexus_arch_gateway_init`
10. `nexus_boot_enter_kernel`
11. `nexus_kernel_init`

Scaffold note:

- `portenta_c33` currently links with `ENTRY(nexus_dummy_entry)` from the generated dummy source path.
- The full startup-vector handoff path is currently wired for `mps2_an505`.

## 3. File/function responsibilities

### A. BSP reset entry and vector ownership (board startup variant)

File:
- `bsp/mps2_an505/secure/src/startup.S`

Functions/symbols:

- `__vector_table_s`
  - Secure vector table object.
  - Provides initial stack pointer and reset vector.

- `reset_handler_s`
  - First reset entry symbol.
  - Branches to `nexus_boot_reset_entry`.

### B. Boot orchestration

File:
- `boot/secure/src/early_boot.c`

Functions:

- `nexus_boot_reset_entry`
  - Resides in `boot/secure/src/reset_entry.c`.
  - Performs secure data copy and BSS zeroing.
  - Calls `nexus_boot_init`.

- `nexus_boot_init`
  - Central boot sequencer.
  - Calls all phase hooks in deterministic order.

- `nexus_boot_enter_kernel`
  - Final handoff into kernel entry.

- `nexus_board_boot_prepare` (weak)
  - Optional board pre-hook before general board early init.

### C. Boot support hooks

Files and functions:

- `boot/secure/src/boot_panic.c`
  - `nexus_boot_panic`
  - Fatal boot fallback hook.

### D. BSP board hooks

Files and functions:

- `bsp/mps2_an505/secure/src/board_boot.c`
  - `nexus_board_boot_prepare`

- `bsp/portenta_c33/secure/src/board_boot.c`
  - Not present in current scaffold.
  - `nexus_board_boot_prepare` falls back to the weak default in `boot/secure/src/early_boot.c`.

- `bsp/mps2_an505/secure/src/board_early_init.c`
  - `nexus_board_early_init`
  - Iterates `nexus_board_irq_table[]` from `bsp/mps2_an505/config/board_irq_table.c`.
  - Calls `NVIC_SetTargetState` / `NVIC_ClearTargetState` per IRQ world policy.
  - Calls `NVIC_SetPriority` per IRQ priority.

- `bsp/portenta_c33/secure/src/board_early_init.c`
  - `nexus_board_early_init`
  - Same pattern as mps2; driven by portenta's own manual IRQ table.

The IRQ table consumed here is maintained manually in
`bsp/<board>/config/board_irq_table.c` and compiled as part of the board's secure static
target.

### E. Arch hooks

Files and functions:

- `arch/arm/cortex-m33/secure/src/interrupt_target_init.c`
  - `nexus_arch_interrupt_target_init`
- `arch/arm/cortex-m33/secure/src/interrupt_target_init.c`
  - `nexus_arch_exception_init`
- `arch/arm/cortex-m33/secure/src/interrupt_target_init.c`
  - `nexus_arch_protection_init`
- `arch/arm/cortex-m33/secure/src/interrupt_target_init.c`
  - `nexus_arch_gateway_init`

### F. Security hook

File:
- `security/src/secure_services.c`

Function:

- `nexus_security_services_init`
  - Secure services setup phase hook before kernel init.

### G. Kernel entry

File:
- `kernel/core/src/kernel_init.c`

Function:

- `nexus_kernel_init`
  - First kernel-owned function called by boot.

## 4. Build wiring relevant to boot flow

- `boot/secure/CMakeLists.txt` conditionally appends
  `bsp/${NEXUS_BOARD}/secure/src/startup.S` into `nexus_boot_secure`.
- This keeps reset entry and boot orchestration in the same boot archive path when board startup exists.
- Root link order places `nexus_boot` before `nexus_kernel_impl` and then calls into kernel via `nexus_boot_enter_kernel`.

## 5. IRQ policy and `nexus_board_early_init` contract

`nexus_board_early_init` is the single point in the boot sequence responsible for
configuring peripheral IRQ world routing. It must complete before `nexus_arch_interrupt_target_init`
enforces any arch-level policy.

The policy data flows as follows:

```
bsp/<board>/config/board_irq_table.c
  manual IRQ descriptors
              │
   nexus_board_early_init()       [bsp/<board>/secure/src/board_early_init.c]
        iterates nexus_board_irq_table[]
        NVIC_SetTargetState / NVIC_ClearTargetState
        NVIC_SetPriority
```

To change an IRQ's world assignment or priority, edit
`bsp/<board>/config/board_irq_table.c` and keep
`bsp/<board>/config/board_irq_map.h` count in sync.

## 6. Guidance for future contributors

When implementing actual logic in these functions:

1. Keep function names stable to preserve board portability.
2. Keep sequencing only in `nexus_boot_init`.
3. Keep CPU register specifics in arch hooks.
4. Keep board hardware specifics in BSP hooks.
5. Keep kernel state creation inside `nexus_kernel_init` and lower kernel modules.

## 7. Minimal implementation policy

Current boot-flow functions are scaffold skeletons. This is intentional.

Before adding real code, document each phase contract in this file and keep the call order unchanged unless there is a cross-board reason to change it.
