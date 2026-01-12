/**
 * @file reset_entry.c
 * @brief Architecture independent reset entry point with C environement setup.
 *
 *
 * @author Shubham Singh
 */

#include <stddef.h>
#include <stdint.h>
#include "nexus_boot_secure.h"

/* Linker-provided symbols for C environement setup */
extern uint8_t _data_src_start_s;
extern uint8_t _data_dst_start_s;
extern uint8_t _data_dst_end_s;
extern uint8_t _bss_src_start_s;
extern uint8_t _bss_dst_start_s;
extern uint8_t _bss_dst_end_s;


void nexus_boot_reset_entry(void)
{
	/* Copy initialized data section from ROM to RAM */
	size_t data_size = (size_t)(&_data_dst_end_s - &_data_dst_start_s);
	if (data_size > 0) {
		uint8_t *src = &_data_src_start_s;
		uint8_t *dst = &_data_dst_start_s;
		for (size_t i = 0; i < data_size; i++) {
			dst[i] = src[i];
		}
	}

	/* Zero BSS Section */
	size_t bss_size = (size_t)(&_bss_dst_end_s - &_bss_dst_start_s);
	if (bss_size > 0) {
		uint8_t *bss = &_bss_dst_start_s;
		for (size_t i = 0; i < bss_size; i++) {
			bss[i] = 0;
		}
	}

	/* C environment is now ready; call architecture-independent boot orchestrator */
	nexus_boot_init();

	/* Boot should not return; if it does, halt */
        while (1) {
                __asm__("nop");
        }
}
