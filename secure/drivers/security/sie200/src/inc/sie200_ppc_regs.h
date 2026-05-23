/**
 * @file sie200_ppc_regs.h
 * @brief Secure-world PPC register definitions.
 *
 * Base addresses remain board-owned and are provided by the selected BSP's
 * peripheral_map.h. This header only describes the reusable PPC/control register
 * blocks and common bit fields used by secure security drivers.
 */

#pragma once

#include <stdint.h>
#include "nexus_io_access.h"
#include "peripheral_map.h"

/**
  \brief  Structure type to access secure privilege control PPC registers.
 */
typedef struct
{
        uint32_t RESERVED0[4U];
  __IOM uint32_t SECRESPCFG;             /*!< Offset: 0x010 (R/W)  Security violation response configuration */
  __IOM uint32_t NSCCFG;                 /*!< Offset: 0x014 (R/W)  Non-secure callable region configuration */
        uint32_t RESERVED1[1U];
  __IM  uint32_t SECMPCINTSTAT;          /*!< Offset: 0x01C (R/ )  Secure MPC interrupt status */
  __IOM uint32_t SECPPCINTSTAT;          /*!< Offset: 0x020 (R/W)  Secure PPC interrupt status */
  __OM  uint32_t SECPPCINTCLR;           /*!< Offset: 0x024 ( /W)  Secure PPC interrupt clear */
  __IOM uint32_t SECPPCINTEN;            /*!< Offset: 0x028 (R/W)  Secure PPC interrupt enable */
        uint32_t RESERVED2[1U];
  __IOM uint32_t SECMSCINTSTAT;          /*!< Offset: 0x030 (R/W)  Secure MSC interrupt status */
  __OM  uint32_t SECMSCINTCLR;           /*!< Offset: 0x034 ( /W)  Secure MSC interrupt clear */
  __IOM uint32_t SECMSCINTEN;            /*!< Offset: 0x038 (R/W)  Secure MSC interrupt enable */
        uint32_t RESERVED3[1U];
  __IOM uint32_t BRGINTSTAT;             /*!< Offset: 0x040 (R/W)  Bridge buffer error interrupt status */
  __OM  uint32_t BRGINTCLR;              /*!< Offset: 0x044 ( /W)  Bridge buffer error interrupt clear */
  __IOM uint32_t BRGINTEN;               /*!< Offset: 0x048 (R/W)  Bridge buffer error interrupt enable */
        uint32_t RESERVED4[1U];
  __IOM uint32_t AHBNSPPC0;              /*!< Offset: 0x050 (R/W)  AHB PPC0 non-secure access */
        uint32_t RESERVED5[3U];
  __IOM uint32_t AHBNSPPCEXP0;           /*!< Offset: 0x060 (R/W)  AHB PPC expansion 0 non-secure access */
  __IOM uint32_t AHBNSPPCEXP1;           /*!< Offset: 0x064 (R/W)  AHB PPC expansion 1 non-secure access */
  __IOM uint32_t AHBNSPPCEXP2;           /*!< Offset: 0x068 (R/W)  AHB PPC expansion 2 non-secure access */
  __IOM uint32_t AHBNSPPCEXP3;           /*!< Offset: 0x06C (R/W)  AHB PPC expansion 3 non-secure access */
  __IOM uint32_t APBNSPPC0;              /*!< Offset: 0x070 (R/W)  APB PPC0 non-secure access */
  __IOM uint32_t APBNSPPC1;              /*!< Offset: 0x074 (R/W)  APB PPC1 non-secure access */
        uint32_t RESERVED6[2U];
  __IOM uint32_t APBNSPPCEXP0;           /*!< Offset: 0x080 (R/W)  APB PPC expansion 0 non-secure access */
  __IOM uint32_t APBNSPPCEXP1;           /*!< Offset: 0x084 (R/W)  APB PPC expansion 1 non-secure access */
  __IOM uint32_t APBNSPPCEXP2;           /*!< Offset: 0x088 (R/W)  APB PPC expansion 2 non-secure access */
  __IOM uint32_t APBNSPPCEXP3;           /*!< Offset: 0x08C (R/W)  APB PPC expansion 3 non-secure access */
  __IOM uint32_t AHBSPPPC0;              /*!< Offset: 0x090 (R/W)  AHB PPC0 secure unprivileged access */
        uint32_t RESERVED7[3U];
  __IOM uint32_t AHBSPPPCEXP0;           /*!< Offset: 0x0A0 (R/W)  AHB PPC expansion 0 secure unprivileged access */
  __IOM uint32_t AHBSPPPCEXP1;           /*!< Offset: 0x0A4 (R/W)  AHB PPC expansion 1 secure unprivileged access */
  __IOM uint32_t AHBSPPPCEXP2;           /*!< Offset: 0x0A8 (R/W)  AHB PPC expansion 2 secure unprivileged access */
  __IOM uint32_t AHBSPPPCEXP3;           /*!< Offset: 0x0AC (R/W)  AHB PPC expansion 3 secure unprivileged access */
  __IOM uint32_t APBSPPPC0;              /*!< Offset: 0x0B0 (R/W)  APB PPC0 secure unprivileged access */
  __IOM uint32_t APBSPPPC1;              /*!< Offset: 0x0B4 (R/W)  APB PPC1 secure unprivileged access */
        uint32_t RESERVED8[2U];
  __IOM uint32_t APBSPPPCEXP0;           /*!< Offset: 0x0C0 (R/W)  APB PPC expansion 0 secure unprivileged access */
  __IOM uint32_t APBSPPPCEXP1;           /*!< Offset: 0x0C4 (R/W)  APB PPC expansion 1 secure unprivileged access */
  __IOM uint32_t APBSPPPCEXP2;           /*!< Offset: 0x0C8 (R/W)  APB PPC expansion 2 secure unprivileged access */
  __IOM uint32_t APBSPPPCEXP3;           /*!< Offset: 0x0CC (R/W)  APB PPC expansion 3 secure unprivileged access */
} SPCTRL_Type;

/**
  \brief  Structure type to access non-secure privilege control PPC registers.
 */
typedef struct
{
        uint32_t RESERVED0[36U];
  __IOM uint32_t AHBNSPPPC0;             /*!< Offset: 0x090 (R/W)  AHB PPC0 non-secure unprivileged access */
        uint32_t RESERVED1[3U];
  __IOM uint32_t AHBNSPPPCEXP0;          /*!< Offset: 0x0A0 (R/W)  AHB PPC expansion 0 non-secure unprivileged access */
  __IOM uint32_t AHBNSPPPCEXP1;          /*!< Offset: 0x0A4 (R/W)  AHB PPC expansion 1 non-secure unprivileged access */
  __IOM uint32_t AHBNSPPPCEXP2;          /*!< Offset: 0x0A8 (R/W)  AHB PPC expansion 2 non-secure unprivileged access */
  __IOM uint32_t AHBNSPPPCEXP3;          /*!< Offset: 0x0AC (R/W)  AHB PPC expansion 3 non-secure unprivileged access */
  __IOM uint32_t APBNSPPPC0;             /*!< Offset: 0x0B0 (R/W)  APB PPC0 non-secure unprivileged access */
  __IOM uint32_t APBNSPPPC1;             /*!< Offset: 0x0B4 (R/W)  APB PPC1 non-secure unprivileged access */
        uint32_t RESERVED2[2U];
  __IOM uint32_t APBNSPPPCEXP0;          /*!< Offset: 0x0C0 (R/W)  APB PPC expansion 0 non-secure unprivileged access */
  __IOM uint32_t APBNSPPPCEXP1;          /*!< Offset: 0x0C4 (R/W)  APB PPC expansion 1 non-secure unprivileged access */
  __IOM uint32_t APBNSPPPCEXP2;          /*!< Offset: 0x0C8 (R/W)  APB PPC expansion 2 non-secure unprivileged access */
  __IOM uint32_t APBNSPPPCEXP3;          /*!< Offset: 0x0CC (R/W)  APB PPC expansion 3 non-secure unprivileged access */
} NSPCTRL_Type;

#define SPCTRL  ((SPCTRL_Type *)SPCTRL_BASE)
#define NSPCTRL ((NSPCTRL_Type *)NSPCTRL_BASE)

#define PPC_APB0_TIMER0_Pos        0U
#define PPC_APB0_TIMER1_Pos        1U
#define PPC_APB0_DUALTIMER_Pos     2U

#define PPC_APB1_S32KTIMER_Pos     0U

#define PPC_APB_EXP0_SSRAM1_MPC_Pos 0U
#define PPC_APB_EXP0_SSRAM2_MPC_Pos 1U
#define PPC_APB_EXP0_SSRAM3_MPC_Pos 2U

#define PPC_APB_EXP1_SPI0_Pos       0U
#define PPC_APB_EXP1_SPI1_Pos       1U
#define PPC_APB_EXP1_SPI2_Pos       2U
#define PPC_APB_EXP1_SPI3_Pos       3U
#define PPC_APB_EXP1_SPI4_Pos       4U
#define PPC_APB_EXP1_UART0_Pos      5U
#define PPC_APB_EXP1_UART1_Pos      6U
#define PPC_APB_EXP1_UART2_Pos      7U
#define PPC_APB_EXP1_UART3_Pos      8U
#define PPC_APB_EXP1_UART4_Pos      9U
#define PPC_APB_EXP1_I2C0_Pos       10U
#define PPC_APB_EXP1_I2C1_Pos       11U
#define PPC_APB_EXP1_I2C2_Pos       12U
#define PPC_APB_EXP1_I2C3_Pos       13U

#define PPC_APB_EXP2_SCC_Pos        0U
#define PPC_APB_EXP2_I2S_AUDIO_Pos  1U
#define PPC_APB_EXP2_FPGAIO_Pos     2U

#define PPC_AHB_EXP0_VGA_Pos        0U
#define PPC_AHB_EXP0_GPIO0_Pos      1U
#define PPC_AHB_EXP0_GPIO1_Pos      2U
#define PPC_AHB_EXP0_GPIO2_Pos      3U
#define PPC_AHB_EXP0_GPIO3_Pos      4U

#define PPC_AHB_EXP1_DMA0_Pos       0U
#define PPC_AHB_EXP1_DMA1_Pos       1U
#define PPC_AHB_EXP1_DMA2_Pos       2U
#define PPC_AHB_EXP1_DMA3_Pos       3U

#define PPC_INT_APB_EXP0_Msk        (1UL << 4U)
#define PPC_INT_APB_EXP1_Msk        (1UL << 5U)
#define PPC_INT_APB_EXP2_Msk        (1UL << 6U)
#define PPC_INT_APB_EXP3_Msk        (1UL << 7U)
#define PPC_INT_AHB_EXP0_Msk        (1UL << 20U)
#define PPC_INT_AHB_EXP1_Msk        (1UL << 21U)
#define PPC_INT_AHB_EXP2_Msk        (1UL << 22U)
#define PPC_INT_AHB_EXP3_Msk        (1UL << 23U)
