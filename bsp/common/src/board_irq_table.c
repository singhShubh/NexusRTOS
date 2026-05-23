#include "interrupt_map.h"

#define NEXUS_IRQ_DESC(irq_number, irq_name, irq_domain, irq_priority) \
    { .irq_n = (irq_number), .name = (irq_name), .domain = (irq_domain), .priority = (irq_priority) },

const nexus_irq_desc_t nexus_board_irq_table[NEXUS_BOARD_IRQ_COUNT] = {
    NEXUS_BOARD_IRQ_TABLE(NEXUS_IRQ_DESC)
};

#undef NEXUS_IRQ_DESC
