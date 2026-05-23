/**
 * @file nexus_boot_secure.h
 * @brief Public entry point for secure boot orchestration.
 *
 * The reset handler calls this API after the secure C runtime has been prepared.
 * The implementation coordinates BSP, architecture, and secure-service setup.
 */

#pragma once

/**
 * @brief Run secure-world boot initialization.
 *
 * This function is expected to perform one-time secure initialization and then,
 * once implemented, hand control to the next boot phase. It should not return to
 * the reset handler in a fully booting system.
 */
void nexus_secure_boot_init(void);
