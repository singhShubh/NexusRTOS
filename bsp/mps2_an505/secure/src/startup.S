.syntax unified
.cpu cortex-m33
.thumb

.section .vector_table_secure, "a", %progbits
.align 8
.global __vector_table_s
.type __vector_table_s, %object

__vector_table_s:
	.word _stack_start_s
	.word reset_handler_s
	.zero 248

.section .text.secure, "ax", %progbits
.align 2
.global reset_handler_s
.type reset_handler_s, %function

reset_handler_s:
	b nexus_boot_reset_entry

.size reset_handler_s, . - reset_handler_s

