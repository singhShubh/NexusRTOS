/**
 * @file nexus_bsp_secure.h
 * @brief Public secure-world BSP API shared by boot and architecture layers.
 *
 * Board-specific secure BSP implementations provide platform preparation and
 * board data through this stable interface. Secure boot calls the BSP init
 * entry point, while architecture code may query board-owned configuration such
 * as interrupt security domains.
 */

#pragma once

#include <stdint.h>
#include "board_common.h"

/**
 * @brief Initialize secure board support before architecture setup.
 *
 * This hook is for board-specific secure setup that must happen early in boot,
 * such as security controller defaults, clock prerequisites, or peripheral
 * firewall configuration. Empty implementations are valid while a board has no
 * secure-side preparation work.
 */
void nexus_secure_bsp_init(void);

/**
 * @brief Return the board interrupt ownership table.
 *
 * @param[out] irq_table Receives a pointer to the static board IRQ descriptor
 *                       table. The storage remains owned by the BSP.
 * @param[out] num_irq   Receives the number of entries in @p irq_table.
 *
 * The secure architecture layer consumes this table to configure which external
 * interrupts target the secure world and which target the non-secure world.
 */
void nexus_secure_bsp_get_irq_domain_config(const nexus_irq_desc_t** irq_table, uint32_t* num_irq);
