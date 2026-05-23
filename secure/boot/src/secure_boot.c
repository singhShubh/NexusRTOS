/**
 * @file secure_boot.c
 * @brief Secure boot initialization sequence.
 *
 * The secure boot layer owns ordering between board preparation, architecture
 * setup, secure service initialization, and the future handoff to non-secure or
 * kernel code. Low-level register programming remains inside the BSP and arch
 * layers.
 */

#include "nexus_bsp_secure.h"
#include "nexus_boot_secure.h"
#include "nexus_arch_secure.h"

/**
 * @brief Run the secure boot phase sequence.
 *
 * Current boot brings up board support and architecture state. Protection setup,
 * secure services, gateway registration, and world handoff are left as explicit
 * future phases so their ordering remains visible.
 */
void nexus_secure_boot_init(void)
{
	nexus_secure_bsp_init();
	nexus_secure_arch_init();
//	nexus_secure_arch_protection_init();
//	nexus_secure_services_init();
//	nexus_secure_arch_gateway_init();
//	nexus_secure_boot_enter_kernel();
}
