#pragma once

#include <stdint.h>

/*
 * IRQ domain assignment used by the BSP IRQ table to declare whether
 * each peripheral interrupt is handled in the secure or non-secure world.
 * Consumed by the BSP platform init path and shared upward to boot and
 * kernel layers.
 */
typedef enum {
    NEXUS_IRQ_DOMAIN_SECURE     = 0,
    NEXUS_IRQ_DOMAIN_NONSECURE  = 1,
} nexus_irq_domain_t;

/*
 * Per-IRQ descriptor stored in the board IRQ table.
 *
 * irq_n    : IRQn value (negative for core exceptions, >=0 for peripheral).
 * name     : human-readable identifier, useful for debug/logging.
 * domain   : secure or non-secure ownership.
 * priority : NVIC priority value to be applied during platform init.
 */
typedef struct {
    int32_t             irq_n;
    const char         *name;
    nexus_irq_domain_t  domain;
    uint32_t            priority;
} nexus_irq_desc_t;
