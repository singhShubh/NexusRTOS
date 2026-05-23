ENTRY(reset_handler_s)

MEMORY
{
    NS_CODE        (rx)  : ORIGIN = 0x00400000, LENGTH = 0x00300000
    NS_RODATA      (r)   : ORIGIN = 0x00700000, LENGTH = 0x00080000
    NS_RESERVED    (r)   : ORIGIN = 0x00780000, LENGTH = 0x00080000

    S_BOOT         (rx)  : ORIGIN = 0x10000000, LENGTH = 0x00080000
    S_KERNEL_CODE  (rx)  : ORIGIN = 0x10080000, LENGTH = 0x00180000
    S_STORAGE      (r)   : ORIGIN = 0x10200000, LENGTH = 0x00200000

    NS_KERNEL      (rwx) : ORIGIN = 0x28000000, LENGTH = 0x00080000
    NS_HEAP        (rwx) : ORIGIN = 0x28080000, LENGTH = 0x00100000
    NS_STACK       (rwx) : ORIGIN = 0x28180000, LENGTH = 0x00080000

    S_DATA         (rwx) : ORIGIN = 0x38200000, LENGTH = 0x00080000
    S_HEAP         (rwx) : ORIGIN = 0x38280000, LENGTH = 0x00080000
    S_STACK        (rwx) : ORIGIN = 0x38300000, LENGTH = 0x00080000
    S_SHARED       (rw)  : ORIGIN = 0x38380000, LENGTH = 0x00080000

    EXT_HEAP       (rwx) : ORIGIN = 0x80000000, LENGTH = 0x00C00000
    EXT_DEVICE_BUF (rw)  : ORIGIN = 0x80C00000, LENGTH = 0x00400000
}

_stack_start_s = ORIGIN(S_STACK) + LENGTH(S_STACK);
_heap_start_s = ORIGIN(S_HEAP);
_heap_end_s = ORIGIN(S_HEAP) + LENGTH(S_HEAP);
_shared_start_s = ORIGIN(S_SHARED);
_shared_end_s = ORIGIN(S_SHARED) + LENGTH(S_SHARED);

_stack_start_ns = ORIGIN(NS_STACK) + LENGTH(NS_STACK);
_heap_start_ns = ORIGIN(NS_HEAP);
_heap_end_ns = ORIGIN(NS_HEAP) + LENGTH(NS_HEAP);
_ext_heap_start_ns = ORIGIN(EXT_HEAP);
_ext_heap_end_ns = ORIGIN(EXT_HEAP) + LENGTH(EXT_HEAP);

SECTIONS
{
    /*
     * World routing policy:
     * - Secure regions pull sections from secure-target archives.
     * - Non-secure regions pull everything else, excluding secure archives.
     *
     * The startup object contributes .vector_table_secure and .text.secure
     * directly, while the remaining secure code is linked from archives.
     */

    /* secure-world sections */

    .text.secure :
    {
		. = ALIGN(4096);
        KEEP(*(.vector_table_secure))
        KEEP(*(.text.secure))
        */libnexus_secure_boot.a:*(.text .text.*)
        */libnexus_secure_services.a:*(.text .text.*)
        */libnexus_secure_arch_*.a:*(.text .text.*)
        */libnexus_secure_bsp_*.a:*(.text .text.*)
		. = ALIGN(4096);
    } > S_BOOT

    .rodata.secure :
    {
		. = ALIGN(4096);
        */libnexus_secure_boot.a:*(.rodata .rodata.*)
        */libnexus_secure_services.a:*(.rodata .rodata.*)
        */libnexus_secure_arch_*.a:*(.rodata .rodata.*)
        */libnexus_secure_bsp_*.a:*(.rodata .rodata.*)
		. = ALIGN(4096);
    } > S_KERNEL_CODE

    .data.secure :
    {
		. = ALIGN(4096);
		_data_dst_start_s = .;
		*/libnexus_secure_boot.a:*(.data .data.*)
		*/libnexus_secure_services.a:*(.data .data.*)
		*/libnexus_secure_arch_*.a:*(.data .data.*)
		*/libnexus_secure_bsp_*.a:*(.data .data.*)
		_data_dst_end_s = .;
		. = ALIGN(4096);
    } > S_DATA AT > S_KERNEL_CODE

    _data_src_start_s = LOADADDR(.data.secure);

    .bss.secure (NOLOAD) :
    {
		. = ALIGN(4096);
		_bss_dst_start_s = .;
		*/libnexus_secure_boot.a:*(.bss .bss.*)
		*/libnexus_secure_services.a:*(.bss .bss.*)
		*/libnexus_secure_arch_*.a:*(.bss .bss.*)
		*/libnexus_secure_bsp_*.a:*(.bss .bss.*)
		*(COMMON)
		_bss_dst_end_s = .;
		. = ALIGN(4096);
    } > S_DATA

    _bss_src_start_s = LOADADDR(.bss.secure);

    /* non-secure-world sections */

    .text.nonsecure :
    {
		. = ALIGN(4096);
        KEEP(*(.vector_table_nonsecure))
        EXCLUDE_FILE(
            */libnexus_secure_boot.a:*
            */libnexus_secure_services.a:*
            */libnexus_secure_arch_*.a:*
            */libnexus_secure_bsp_*.a:*
        ) *(.text*)
		. = ALIGN(4096);
    } > NS_CODE

    .rodata.nonsecure :
    {
		. = ALIGN(4096);
        EXCLUDE_FILE(
            */libnexus_secure_boot.a:*
            */libnexus_secure_services.a:*
            */libnexus_secure_arch_*.a:*
            */libnexus_secure_bsp_*.a:*
        ) *(.rodata*)
		. = ALIGN(4096);
    } > NS_RODATA

    .data.nonsecure :
    {
		. = ALIGN(4096);
		_data_dst_start_ns = .;
        EXCLUDE_FILE(
            */libnexus_secure_boot.a:*
            */libnexus_secure_services.a:*
            */libnexus_secure_arch_*.a:*
            */libnexus_secure_bsp_*.a:*
        ) *(.data*)
		_data_dst_end_ns = .;
		. = ALIGN(4096);
    } > NS_KERNEL AT > NS_CODE

    _data_src_start_ns = LOADADDR(.data.nonsecure);

    .bss.nonsecure (NOLOAD) :
    {
		. = ALIGN(4096);
		_bss_dst_start_ns = .;
        EXCLUDE_FILE(
            */libnexus_secure_boot.a:*
            */libnexus_secure_services.a:*
            */libnexus_secure_arch_*.a:*
            */libnexus_secure_bsp_*.a:*
        ) *(.bss*)
		*(COMMON)
		_bss_dst_end_ns = .;
		. = ALIGN(4096);
    } > NS_KERNEL

    _bss_src_start_ns = LOADADDR(.bss.nonsecure);

    /DISCARD/ :
    {
	*(.comment)
	*(.note*)
	*(.eh_frame*)
    }

    ASSERT(ADDR(.text.secure) >= ORIGIN(S_BOOT), "secure text starts outside S_BOOT")
    ASSERT(ADDR(.text.secure) + SIZEOF(.text.secure) <= ORIGIN(S_BOOT) + LENGTH(S_BOOT), "secure boot region overflow")
    ASSERT(ADDR(.rodata.secure) + SIZEOF(.rodata.secure) <= ORIGIN(S_KERNEL_CODE) + LENGTH(S_KERNEL_CODE), "secure kernel code region overflow")
    ASSERT(ADDR(.data.secure) + SIZEOF(.data.secure) <= ORIGIN(S_DATA) + LENGTH(S_DATA), "secure data region overflow")
    ASSERT(ADDR(.bss.secure) + SIZEOF(.bss.secure) <= ORIGIN(S_DATA) + LENGTH(S_DATA), "secure bss region overflow")
    ASSERT(ADDR(.text.nonsecure) + SIZEOF(.text.nonsecure) <= ORIGIN(NS_CODE) + LENGTH(NS_CODE), "non-secure code region overflow")
    ASSERT(ADDR(.rodata.nonsecure) + SIZEOF(.rodata.nonsecure) <= ORIGIN(NS_RODATA) + LENGTH(NS_RODATA), "non-secure rodata region overflow")
    ASSERT(ADDR(.data.nonsecure) + SIZEOF(.data.nonsecure) <= ORIGIN(NS_KERNEL) + LENGTH(NS_KERNEL), "non-secure data region overflow")
    ASSERT(ADDR(.bss.nonsecure) + SIZEOF(.bss.nonsecure) <= ORIGIN(NS_KERNEL) + LENGTH(NS_KERNEL), "non-secure bss region overflow")
}
