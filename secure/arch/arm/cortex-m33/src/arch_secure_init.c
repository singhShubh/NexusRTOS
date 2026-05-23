/**
 * @file arch_secure_init.c
 * @brief Cortex-M33 implementation of the public secure architecture init API.
 */

#include "nexus_arch_secure.h"
#include "armv8m_secure_init.h"

/**
 * @brief Initialize Cortex-M33 secure architecture state.
 *
 * The order is intentional: the secure vector table is installed first so any
 * subsequent secure fault or interrupt uses secure handlers, then board IRQ
 * ownership is applied to NVIC ITNS registers.
 */
void nexus_secure_arch_init(void)
{
	arch_exceptions_init();
	arch_irq_init();
}
