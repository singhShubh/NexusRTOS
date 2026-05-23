/**
 * @file arch_exceptions.c
 * @brief Secure exception vector table setup for Armv8-M Cortex-M33.
 */

#include <stdint.h>
#include "armv8m_scb.h"
#include "armv8m_barrier.h"
#include "armv8m_secure_init.h"

extern uint32_t _stack_start_s;
extern void nexus_secure_boot_reset_handler(void);

/**
 * @brief Default secure exception handler used until real handlers exist.
 */
void default_handler_s(void)
{
	while (1) {
	}
}

/**
 * @brief SecureFault handler placeholder.
 */
void secure_fault_handler(void)
{
	while (1) {
	}
}

/**
 * @brief Minimal secure vector table placed in secure text.
 *
 * The table contains core exception entries only. Board peripheral vectors can
 * be added later when secure interrupt dispatch is implemented.
 */
__attribute__((section(".text.secure"), aligned(256), used))
const uintptr_t nexus_secure_vector_table[] =
{
	(uintptr_t)&_stack_start_s,
	(uintptr_t)nexus_secure_boot_reset_handler,
	(uintptr_t)default_handler_s,
	(uintptr_t)default_handler_s,
	(uintptr_t)default_handler_s,
	(uintptr_t)default_handler_s,
	(uintptr_t)default_handler_s,
	(uintptr_t)secure_fault_handler,
	0,
	0,
	0,
	(uintptr_t)default_handler_s,
	(uintptr_t)default_handler_s,
	0,
	(uintptr_t)default_handler_s,
	(uintptr_t)default_handler_s,
};

/**
 * @brief Point secure VTOR at the Nexus secure vector table.
 *
 * Barriers ensure the VTOR update is visible before instruction execution can
 * observe subsequent exception behavior.
 */
void arch_exceptions_init(void)
{
	ARMV8M_SCB->VTOR = (uint32_t)nexus_secure_vector_table;
	nexus_arch_dsb();
	nexus_arch_isb();
}
