#include "board_irq_map.h"

const nexus_irq_desc_t nexus_board_irq_table[NEXUS_BOARD_IRQ_COUNT] = {
    { .irq_n = 0, .name = "UART0_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 1, .name = "UART1_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 2, .name = "UART2_IRQ", .domain = NEXUS_IRQ_DOMAIN_SECURE, .priority = 2U },
    { .irq_n = 3, .name = "UART3_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 4, .name = "UART4_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 8, .name = "TIMER0_IRQ", .domain = NEXUS_IRQ_DOMAIN_SECURE, .priority = 2U },
    { .irq_n = 9, .name = "TIMER1_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 10, .name = "DUALTIMER_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 11, .name = "SPI0_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 13, .name = "SPI1_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 14, .name = "I2C0_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 15, .name = "I2C1_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 27, .name = "DMA_IRQ", .domain = NEXUS_IRQ_DOMAIN_SECURE, .priority = 2U },
    { .irq_n = 43, .name = "GPIO0_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
    { .irq_n = 44, .name = "GPIO1_IRQ", .domain = NEXUS_IRQ_DOMAIN_NONSECURE, .priority = 4U },
};
