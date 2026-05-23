/**
 * @file arch_irq.c
 * @brief Cortex-M33 secure interrupt setup helpers.
 */

#include <stdint.h>
#include "armv8m_nvic.h"
#include "armv8m_secure_init.h"
#include "nexus_bsp_secure.h"

/**
 * @brief Apply BSP IRQ domain assignments to NVIC ITNS registers.
 *
 * Each BSP IRQ descriptor uses the external interrupt input number as the bit
 * position in the NVIC Interrupt Target Non-secure register bank. A set ITNS bit
 * routes the interrupt to the non-secure world; a clear bit leaves it secure.
 */
void arch_irq_init(void)
{
	uint32_t reg_index;
	uint32_t reg_bit;
	uint32_t num_irq;
	const nexus_irq_desc_t* irq_table;

	nexus_secure_bsp_get_irq_domain_config(&irq_table, &num_irq);
	for (uint32_t i = 0U; i < num_irq; i++)
	{
		if (NEXUS_IRQ_DOMAIN_NONSECURE == irq_table[i].domain)
		{
			reg_bit = (uint32_t)irq_table[i].irq_n % 32U;
			reg_index = (uint32_t)irq_table[i].irq_n / 32U;
			ARMV8M_NVIC->ITNS[reg_index] |= (1UL << reg_bit);
		}
	}
}
