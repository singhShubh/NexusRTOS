# Dependency Model

## Allowed high-level flow

```text
app
  ↓
services
  ↓
drivers
  ↓
kernel/api
  ↓
kernel/internal + kernel implementation
  ↓
arch / security / bsp
```

## Target-level policy

### Applications
May use:
- `nexus_kernel_api`
- `nexus_services`

Must not use:
- `nexus_kernel_internal_api`
- `nexus_security`
- `nexus_arch`

### Services
May use:
- `nexus_kernel_api`
- `nexus_drivers`

Must not use:
- `nexus_kernel_internal_api`
- `nexus_security`
- `nexus_arch`
- `nexus_bsp` internals

### Drivers
May use:
- `nexus_kernel_api`
- `nexus_bsp_public`

Must not use:
- `nexus_services`
- `nexus_kernel_internal_api` unless explicitly whitelisted

### Kernel implementation modules
May use:
- `nexus_kernel_api`
- `nexus_kernel_internal_api`
- other kernel implementation modules as needed

## Example violation

If `services/audio/src/audio_service.c` attempts:

```c
#include "nexus_internal.h"
```

the build should fail because `services/audio` links only against `nexus_kernel_api` and `nexus_drivers`,
neither of which exports `kernel/internal/include`.
