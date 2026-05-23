/**
 * @file board_irq_table.c
 * @brief AN505 secure interrupt ownership table provider.
 *
 * The table is generated from the board configuration macro list so secure and
 * non-secure ownership data stays in a single board-specific source of truth.
 */

#include "interrupt_map.h"

/** Convert one board IRQ macro entry into a nexus_irq_desc_t initializer. */
#define NEXUS_IRQ_DESC(irq_number, irq_name, irq_domain, irq_priority) \
	{ \
		.irq_n = irq_number, \
		.name = irq_name, \
		.domain = irq_domain, \
		.priority = irq_priority \
	},

/** Static AN505 interrupt domain table consumed by the secure arch layer. */
const nexus_irq_desc_t nexus_irq_table[NEXUS_BOARD_IRQ_COUNT] =
{
	NEXUS_BOARD_IRQ_TABLE(NEXUS_IRQ_DESC)
};

void nexus_secure_bsp_get_irq_domain_config(const nexus_irq_desc_t** irq_table, uint32_t* num_irq)
{
	*num_irq = NEXUS_BOARD_IRQ_COUNT;
	*irq_table = nexus_irq_table;
}
