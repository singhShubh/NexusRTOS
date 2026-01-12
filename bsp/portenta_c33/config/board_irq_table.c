#include "board_irq_map.h"

const nexus_irq_desc_t nexus_board_irq_table[NEXUS_BOARD_IRQ_COUNT] = {
    { .irq_n = 0, .name = "UART3_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 1, .name = "UART4_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 15, .name = "SPI1_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 23, .name = "I2C1_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 24, .name = "I2C2_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 28, .name = "TIM2_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 29, .name = "TIM3_IRQ", .domain = NEXUS_IRQ_DOMAIN_SECURE, .priority = 2U },
    { .irq_n = 56, .name = "DMA1_Stream0_IRQ", .domain = NEXUS_IRQ_DOMAIN_SECURE, .priority = 2U },
};
