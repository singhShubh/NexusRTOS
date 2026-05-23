/**
 * @file boot_panic.c
 * @brief Secure boot panic hook.
 *
 * This placeholder provides a central location for unrecoverable secure boot
 * failures. Future implementations can add platform logging, fault records, or
 * a board-specific halt/reset policy.
 */

/**
 * @brief Handle an unrecoverable secure boot failure.
 *
 * The current implementation intentionally performs no action because the boot
 * path does not yet route failures through this hook.
 */
void nexus_boot_panic(void)
{
}
