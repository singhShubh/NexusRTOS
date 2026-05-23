/**
 * @file armv8m_secure_init.h
 * @brief Private Cortex-M33 secure architecture initialization hooks.
 *
 * This header is internal to the Cortex-M33 secure architecture module. It lets
 * arch_secure_init.c compose implementation steps without exposing those steps
 * to secure boot or other layers.
 */

#pragma once

/** @brief Install and activate the secure vector table. */
void arch_exceptions_init(void);

/** @brief Configure NVIC interrupt target security domains from BSP data. */
void arch_irq_init(void);
