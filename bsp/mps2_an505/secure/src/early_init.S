.syntax unified
.cpu cortex-m33
.thumb

/* ------------------------------------------------------------------------- */
/*                              Linker Symbols                               */
/* ------------------------------------------------------------------------- */

.word _stack_start_ns

.word _stack_start_s
.word _data_src_start_s
.word _data_dst_start_s
.word _data_dst_end_s
.word _bss_src_start_s
.word _bss_dst_start_s
.word _bss_dst_end_s

/* ------------------------------------------------------------------------- */
/*                     early initialization functions                        */
/* ------------------------------------------------------------------------- */
.section .text.secure
.align 1
.type , %object

__vector_table_s:
	.word _secure_stack_start
	.word reset_handler
	.zero 248


.section .text.secure
.type reset_handler, %function


    
