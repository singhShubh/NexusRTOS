/**
 * @file sie200_mpc_regs.h
 * @brief Secure-world MPC register definitions.
 *
 * Base addresses remain board-owned and are provided by the selected BSP's
 * peripheral_map.h. This header only describes the reusable MPC register block
 * and common bit fields used by secure security drivers.
 */

#pragma once

#include <stdint.h>
#include "nexus_io_access.h"
#include "peripheral_map.h"

/**
  \brief  Structure type to access an Arm SIE-200 Memory Protection Controller.
 */
typedef struct
{
  __IOM uint32_t CTRL;             /*!< Offset: 0x000 (R/W)  Control register */
        uint32_t RESERVED0[3U];
  __IM  uint32_t BLK_MAX;          /*!< Offset: 0x010 (R/ )  Maximum block index */
  __IM  uint32_t BLK_CFG;          /*!< Offset: 0x014 (R/ )  Block configuration */
  __IOM uint32_t BLK_IDX;          /*!< Offset: 0x018 (R/W)  Block lookup index */
  __IOM uint32_t BLK_LUT;          /*!< Offset: 0x01C (R/W)  Block lookup value */
  __IOM uint32_t INT_STAT;         /*!< Offset: 0x020 (R/W)  Interrupt status */
  __OM  uint32_t INT_CLEAR;        /*!< Offset: 0x024 ( /W)  Interrupt clear */
  __IOM uint32_t INT_EN;           /*!< Offset: 0x028 (R/W)  Interrupt enable */
  __IM  uint32_t INT_INFO1;        /*!< Offset: 0x02C (R/ )  Interrupt address information */
  __IM  uint32_t INT_INFO2;        /*!< Offset: 0x030 (R/ )  Interrupt attribute information */
  __OM  uint32_t INT_SET;          /*!< Offset: 0x034 ( /W)  Interrupt set */
        uint32_t RESERVED1[998U];
  __IM  uint32_t PIDR4;            /*!< Offset: 0xFD0 (R/ )  Peripheral ID 4 */
  __IM  uint32_t PIDR5;            /*!< Offset: 0xFD4 (R/ )  Peripheral ID 5 */
  __IM  uint32_t PIDR6;            /*!< Offset: 0xFD8 (R/ )  Peripheral ID 6 */
  __IM  uint32_t PIDR7;            /*!< Offset: 0xFDC (R/ )  Peripheral ID 7 */
  __IM  uint32_t PIDR0;            /*!< Offset: 0xFE0 (R/ )  Peripheral ID 0 */
  __IM  uint32_t PIDR1;            /*!< Offset: 0xFE4 (R/ )  Peripheral ID 1 */
  __IM  uint32_t PIDR2;            /*!< Offset: 0xFE8 (R/ )  Peripheral ID 2 */
  __IM  uint32_t PIDR3;            /*!< Offset: 0xFEC (R/ )  Peripheral ID 3 */
  __IM  uint32_t CIDR0;            /*!< Offset: 0xFF0 (R/ )  Component ID 0 */
  __IM  uint32_t CIDR1;            /*!< Offset: 0xFF4 (R/ )  Component ID 1 */
  __IM  uint32_t CIDR2;            /*!< Offset: 0xFF8 (R/ )  Component ID 2 */
  __IM  uint32_t CIDR3;            /*!< Offset: 0xFFC (R/ )  Component ID 3 */
} MPC_Type;

#define MPC_CTRL_SEC_RESP_Msk   (1UL << 4U)
#define MPC_CTRL_AUTOINC_Msk    (1UL << 8U)
#define MPC_CTRL_LOCKDOWN_Msk   (1UL << 31U)

#define MPC_LUT_NS_Pos(block)   ((uint32_t)(block))
#define MPC_LUT_NS_Msk(block)   (1UL << MPC_LUT_NS_Pos(block))
#define MPC_LUT_ALL_NS_Msk      0xFFFFFFFFUL

#define MPC_INT_IRQ_Msk         (1UL << 0U)
#define MPC_INT_INFO2_HMASTER_Pos 0U
#define MPC_INT_INFO2_HMASTER_Msk (0xFFFFUL << MPC_INT_INFO2_HMASTER_Pos)
#define MPC_INT_INFO2_HNONSEC_Msk (1UL << 16U)
#define MPC_INT_INFO2_CFG_NS_Msk  (1UL << 17U)
