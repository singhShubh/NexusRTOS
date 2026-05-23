/**
 * @file board_init.c
 * @brief Secure BSP initialization for the Arm MPS2+ AN505 board.
 *
 * Board-specific secure initialization is centralized here. The current board
 * support does not need early hardware programming yet, but the structure keeps
 * future PPC/MPC or clock setup out of the generic boot layer.
 */

#include "nexus_bsp_secure.h"

/**
 * @brief Perform AN505 secure-board boot preparation.
 */
static void nexus_secure_board_boot_prepare(void)
{
}

/**
 * @brief Public secure BSP initialization entry point for AN505.
 */
void nexus_secure_bsp_init(void)
{
	nexus_secure_board_boot_prepare();
}
