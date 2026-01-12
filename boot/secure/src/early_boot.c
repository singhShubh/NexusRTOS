
#include "nexus_boot_secure.h"

void nexus_board_early_init(void);
void nexus_arch_exception_init(void);
void nexus_arch_interrupt_target_init(void);
void nexus_arch_protection_init(void);
void nexus_security_services_init(void);
void nexus_arch_gateway_init(void);
void nexus_kernel_init(void);

__attribute__((weak)) void nexus_board_boot_prepare(void)
{
}

void nexus_boot_enter_kernel(void)
{
	nexus_kernel_init();
}

void nexus_boot_init(void)
{
	nexus_board_early_init();
	nexus_arch_exception_init();
	nexus_arch_interrupt_target_init();
	nexus_arch_protection_init();
	nexus_security_services_init();
	nexus_arch_gateway_init();
	nexus_boot_enter_kernel();
}
