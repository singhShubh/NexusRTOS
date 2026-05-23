# TODO

## Dependency hardening compliance snapshot

Date: 2026-05-20
Status: compliant with current README dependency-hardening rules.

### Verified rules

1. Drivers depend only on nexus_kernel and nexus_bsp_public.
2. Kernel implementation modules depend on nexus_kernel_internal_api and kernel implementation modules as needed.
3. app depends only on nexus_kernel.
4. No source-level kernel internal leakage found under app or drivers.
5. Legacy kernel public/syscall module split (`os/kernel/api`, `os/kernel/syscall`) is removed.

### Verified file locations

- README rules source: README.md
- Drivers dependencies:
  - drivers/dma/CMakeLists.txt
  - drivers/timer/CMakeLists.txt
  - drivers/uart/CMakeLists.txt
- app dependency:
  - app/CMakeLists.txt
- Kernel implementation dependencies:
  - os/kernel/core/CMakeLists.txt
  - os/kernel/sched/CMakeLists.txt
  - os/kernel/task/CMakeLists.txt
  - os/kernel/irq/CMakeLists.txt
  - os/kernel/mem/CMakeLists.txt
  - os/kernel/ipc/CMakeLists.txt
  - os/kernel/subsys/workqueue/CMakeLists.txt
  - os/kernel/subsys/timer/CMakeLists.txt

## Follow-up actions

1. Re-run this compliance check whenever module dependencies are edited.
