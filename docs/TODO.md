# TODO

## Dependency hardening compliance snapshot

Date: 2026-05-05
Status: compliant with current README dependency-hardening rules.

### Verified rules

1. Services depend only on nexus_kernel_api and nexus_drivers.
2. Drivers depend only on nexus_kernel_api and nexus_bsp_public.
3. Kernel implementation modules depend on nexus_kernel_api, nexus_kernel_internal_api, and kernel implementation modules as needed.
4. app/nonsecure depends only on nexus_kernel_api and nexus_services.
5. No source-level kernel internal leakage found under services, app, or drivers.

### Verified file locations

- README rules source: README.md
- Services dependencies:
  - services/audio/CMakeLists.txt
  - services/logging/CMakeLists.txt
  - services/shell/CMakeLists.txt
- Drivers dependencies:
  - drivers/audio/CMakeLists.txt
  - drivers/dma/CMakeLists.txt
  - drivers/timer/CMakeLists.txt
  - drivers/uart/CMakeLists.txt
- app/nonsecure dependency:
  - app/nonsecure/CMakeLists.txt
- Kernel implementation dependencies:
  - kernel/core/CMakeLists.txt
  - kernel/sched/CMakeLists.txt
  - kernel/task/CMakeLists.txt
  - kernel/irq/CMakeLists.txt
  - kernel/mem/CMakeLists.txt
  - kernel/ipc/CMakeLists.txt
  - kernel/syscall/CMakeLists.txt
  - kernel/subsys/workqueue/CMakeLists.txt
  - kernel/subsys/timer/CMakeLists.txt
  - kernel/subsys/dma/CMakeLists.txt

## Follow-up actions

1. Add a CI guard that fails if nexus_kernel_internal_api appears in non-kernel CMake targets.
2. Add a CI/source guard that fails if services, app, or drivers include kernel/internal headers.
3. Re-run this compliance check whenever module dependencies are edited.
