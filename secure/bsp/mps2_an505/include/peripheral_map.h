/**
 * @file peripheral_map.h
 * @brief Secure-only AN505 peripheral address aliases.
 *
 * Includes the common AN505 peripheral map and adds secure-side controller
 * addresses for SPCTRL/NSPCTRL and SSRAM MPC register windows.
 */

#pragma once

#include "../../../../bsp_config/mps2_an505/peripheral_map.h"

/* Secure security control register blocks. */
#define SPCTRL_BASE             0x50080000UL
#define NSPCTRL_BASE            0x40080000UL

/* Secure APB PPC expansion 0: memory protection controllers. */
#define SSRAM1_MPC_BASE         0x58007000UL
#define SSRAM1_MPC_SIZE         PERIPH_WINDOW_SIZE
#define SSRAM2_MPC_BASE         0x58008000UL
#define SSRAM2_MPC_SIZE         PERIPH_WINDOW_SIZE
#define SSRAM3_MPC_BASE         0x58009000UL
#define SSRAM3_MPC_SIZE         PERIPH_WINDOW_SIZE

/* Secure convenience ranges for PPC programming. */
#define APB_PPC0_BASE           TIMER0_BASE
#define APB_PPC0_LIMIT          0x40002FFFUL
#define APB_PPC1_BASE           S32KTIMER_BASE
#define APB_PPC1_LIMIT          0x4002FFFFUL
#define APB_PPCEPERIPH0_BASE    SSRAM1_MPC_BASE
#define APB_PPCEPERIPH0_LIMIT   0x58009FFFUL
#define APB_PPCEPERIPH1_BASE    UART0_BASE
#define APB_PPCEPERIPH1_LIMIT   0x4020DFFFUL
#define APB_PPCEPERIPH2_BASE    SCC_BASE
#define APB_PPCEPERIPH2_LIMIT   0x40302FFFUL
#define AHB_PPCEPERIPH0_VGA_BASE   VGA_BASE
#define AHB_PPCEPERIPH0_VGA_SIZE   VGA_SIZE
#define AHB_PPCEPERIPH0_GPIO0_BASE GPIO0_BASE
#define AHB_PPCEPERIPH0_GPIO0_SIZE GPIO0_SIZE
#define AHB_PPCEPERIPH0_GPIO1_BASE GPIO1_BASE
#define AHB_PPCEPERIPH0_GPIO1_SIZE GPIO1_SIZE
#define AHB_PPCEPERIPH0_GPIO2_BASE GPIO2_BASE
#define AHB_PPCEPERIPH0_GPIO2_SIZE GPIO2_SIZE
#define AHB_PPCEPERIPH0_GPIO3_BASE GPIO3_BASE
#define AHB_PPCEPERIPH0_GPIO3_SIZE GPIO3_SIZE
#define AHB_PPCEPERIPH1_BASE    DMA0_BASE
#define AHB_PPCEPERIPH1_LIMIT   0x40113FFFUL
