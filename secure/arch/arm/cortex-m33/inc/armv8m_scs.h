/**
 * @file armv8m_scs.h
 * @brief Armv8-M System Control Space base addresses.
 *
 * These constants locate core-private register blocks such as NVIC, SCB, MPU,
 * and SAU in the Armv8-M System Control Space.
 */

#pragma once


#define ARMV8M_SCS_BASE  (0xE000E000UL)
#define ARMV8M_NVIC_BASE (ARMV8M_SCS_BASE + 0x0100UL)
#define ARMV8M_SCB_BASE  (ARMV8M_SCS_BASE + 0x0D00UL)
#define ARMV8M_MPU_BASE  (ARMV8M_SCS_BASE + 0x0D90UL)
#define ARMV8M_SAU_BASE  (ARMV8M_SCS_BASE + 0x0DD0UL)
