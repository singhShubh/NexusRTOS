/**
 * @file nexus_secure_services.h
 * @brief Public secure-service initialization API.
 *
 * Secure services are callable facilities owned by the secure world. The boot
 * layer initializes them after low-level BSP and architecture setup, before any
 * future transition to non-secure application code.
 */

#pragma once

/**
 * @brief Initialize secure-world service state.
 *
 * The current implementation is intentionally empty; future work can register
 * non-secure callable gateways or initialize secure-only service backends here.
 */
void nexus_secure_services_init(void);
