/**
 * @file reset_entry.c
 * @brief Secure reset handler and minimal C runtime setup.
 *
 * This file contains the architecture-independent reset path used by the secure
 * image. It initializes the secure data and BSS sections using linker-provided
 * symbols before handing control to the secure boot orchestrator.
 */

#include <stddef.h>
#include <stdint.h>
#include "nexus_boot_secure.h"

/* Linker-provided bounds for secure initialized data and zero-initialized data. */
extern uint8_t _data_src_start_s;
extern uint8_t _data_dst_start_s;
extern uint8_t _data_dst_end_s;
extern uint8_t _bss_dst_start_s;
extern uint8_t _bss_dst_end_s;

/**
 * @brief Secure reset handler entered from the secure vector table.
 *
 * Copies secure .data from its load address to RAM, clears secure .bss, and then
 * invokes the higher-level secure boot sequence. If boot unexpectedly returns,
 * execution is parked in a low-impact infinite loop.
 */
void nexus_secure_boot_reset_handler(void)
{
	const size_t data_size = (size_t)(&_data_dst_end_s - &_data_dst_start_s);
	if (data_size > 0U) {
		uint8_t *src = &_data_src_start_s;
		uint8_t *dst = &_data_dst_start_s;
		for (size_t i = 0U; i < data_size; i++) {
			dst[i] = src[i];
		}
	}

	const size_t bss_size = (size_t)(&_bss_dst_end_s - &_bss_dst_start_s);
	if (bss_size > 0U) {
		uint8_t *bss = &_bss_dst_start_s;
		for (size_t i = 0U; i < bss_size; i++) {
			bss[i] = 0U;
		}
	}

	nexus_secure_boot_init();

	while (1) {
		__asm__("nop");
	}
}
