/**
 * @file nexus_arch_secure.h
 * @brief Public secure-world architecture initialization API.
 *
 * The secure boot layer includes this board-independent header to initialize
 * the selected secure architecture implementation. Architecture-specific code
 * keeps register programming details private behind this API.
 */

#pragma once

/**
 * @brief Initialize secure-world architecture state.
 *
 * Implemented by the selected secure architecture backend. For Armv8-M this
 * installs the secure vector table and applies board-provided interrupt domain
 * ownership to the NVIC Interrupt Target Non-secure registers.
 */
void nexus_secure_arch_init(void);
