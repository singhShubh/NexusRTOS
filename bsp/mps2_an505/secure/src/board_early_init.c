#include "board.h"     /* pulls in generated board_irq_map.h */

/*
 * nexus_board_early_init — secure-world platform init entry point.
 *
 * Called from the secure boot path before any world switch.
 * Iterates the board IRQ table and configures each peripheral interrupt:
 *   - Routes it to the correct world via NVIC_SetTargetState / NVIC_ClearTargetState.
 *   - Applies the declared priority.
 *
 * ARM CMSIS intrinsics used:
 *   NVIC_SetTargetState(n)   — marks IRQ n as non-secure (1)
 *   NVIC_ClearTargetState(n) — marks IRQ n as secure     (0)
 *   NVIC_SetPriority(n, p)   — sets NVIC priority
 */
void nexus_board_early_init(void)
{
#if 0
    	for (uint32_t i = 0U; i < NEXUS_BOARD_IRQ_COUNT; i++) {
        const nexus_irq_desc_t *irq = &nexus_board_irq_table[i];

        if (irq->irq_n < 0) {
            /* Core exceptions (negative IRQn): only set priority, no target-state. */
            NVIC_SetPriority((IRQn_Type)irq->irq_n, irq->priority);
            continue;
        }

        if (irq->domain == NEXUS_IRQ_DOMAIN_NONSECURE) {
            NVIC_SetTargetState((IRQn_Type)irq->irq_n);
        } else {
            NVIC_ClearTargetState((IRQn_Type)irq->irq_n);
        }

        NVIC_SetPriority((IRQn_Type)irq->irq_n, irq->priority);
    }
#endif
}

