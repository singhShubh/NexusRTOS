/*
 * @file startup.S
 * @brief AN505 secure reset vector and assembly trampoline.
 *
 * The linker places this secure vector table at the secure image entry point.
 * The reset vector branches immediately to the C reset handler, which performs
 * data/BSS initialization before entering the secure boot layer.
 */

.syntax unified
.cpu cortex-m33
.thumb

/* Initial secure vector table used at reset before VTOR is reprogrammed. */
.section .vector_table_secure, "a", %progbits
.align 8
.global __vector_table_s
.type __vector_table_s, %object

__vector_table_s:
	.word _stack_start_s
	.word reset_handler_s
	.zero 56

/* Keep the assembly reset handler tiny; C owns runtime setup. */
.section .text.secure, "ax", %progbits
.align 2
.global reset_handler_s
.type reset_handler_s, %function

reset_handler_s:
	b nexus_secure_boot_reset_handler

.size reset_handler_s, . - reset_handler_s
