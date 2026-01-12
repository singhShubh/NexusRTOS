ENTRY(reset_handler_s)

MEMORY
{
    FLASH_NS (rx)  : ORIGIN = 0x00400000, LENGTH = 0x003FFFFF	/* 4M */
    FLASH_S  (rx)  : ORIGIN = 0x10000000, LENGTH = 0x003FFFFF	/* 4M */

    RAM_NS   (rwx) : ORIGIN = 0x28000000, LENGTH = 0x001FFFFF	/* 2M */
    RAM_S    (rwx) : ORIGIN = 0x38200000, LENGTH = 0x001FFFFF	/* 2M */

    RAM2_NS  (rwx) : ORIGIN = 0x80000000, LENGTH = 0x00FFFFFF	/* 16M */
}

_stack_start_s = ORIGIN(RAM_S) + LENGTH(RAM_S);

_stack_start_ns = ORIGIN(RAM_NS) + LENGTH(RAM_NS);

SECTIONS
{
    /*
     * World routing policy:
     * - Secure regions pull sections from secure-target archives.
     * - Non-secure regions pull everything else, excluding secure archives.
     *
     * This avoids fragile filename-based matching such as *secure*.obj.
     */

    /* secure-world sections */

    .text.secure :
    {
        KEEP(*(.vector_table_secure))
        */libnexus_boot_secure.a:*(.text .text.*)
        */libnexus_security.a:*(.text .text.*)
        */libnexus_arch_*_secure.a:*(.text .text.*)
        */libnexus_bsp_*_secure.a:*(.text .text.*)
        */libnexus_app_secure.a:*(.text .text.*)
    } > FLASH_S

    .rodata.secure :
    {
        */libnexus_boot_secure.a:*(.rodata .rodata.*)
        */libnexus_security.a:*(.rodata .rodata.*)
        */libnexus_arch_*_secure.a:*(.rodata .rodata.*)
        */libnexus_bsp_*_secure.a:*(.rodata .rodata.*)
        */libnexus_app_secure.a:*(.rodata .rodata.*)
    } > FLASH_S

    .data.secure :
    {
	_data_dst_start_s = .;
	*/libnexus_boot_secure.a:*(.data .data.*)
	*/libnexus_security.a:*(.data .data.*)
	*/libnexus_arch_*_secure.a:*(.data .data.*)
	*/libnexus_bsp_*_secure.a:*(.data .data.*)
	*/libnexus_app_secure.a:*(.data .data.*)
	_data_dst_end_s = .;
    } > RAM_S AT > FLASH_S

    _data_src_start_s = LOADADDR(.data.secure);

    .bss.secure (NOLOAD) :
    {
	_bss_dst_start_s = .;
	*/libnexus_boot_secure.a:*(.bss .bss.*)
	*/libnexus_security.a:*(.bss .bss.*)
	*/libnexus_arch_*_secure.a:*(.bss .bss.*)
	*/libnexus_bsp_*_secure.a:*(.bss .bss.*)
	*/libnexus_app_secure.a:*(.bss .bss.*)
	*(COMMON)
	_bss_dst_end_s = .;
    } > RAM_S

    _bss_src_start_s = LOADADDR(.bss.secure);

    /* non-secure-world sections */

    .text.nonsecure :
    {
        KEEP(*(.vector_table_nonsecure))
        EXCLUDE_FILE(
            */libnexus_boot_secure.a:*
            */libnexus_security.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_bsp_*_secure.a:*
            */libnexus_app_secure.a:*
        ) *(.text*)
    } > FLASH_NS

    .rodata.nonsecure :
    {
        EXCLUDE_FILE(
            */libnexus_boot_secure.a:*
            */libnexus_security.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_bsp_*_secure.a:*
            */libnexus_app_secure.a:*
        ) *(.rodata*)
    } > FLASH_NS

    .data.nonsecure :
    {
	_data_dst_start_ns = .;
        EXCLUDE_FILE(
            */libnexus_boot_secure.a:*
            */libnexus_security.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_bsp_*_secure.a:*
            */libnexus_app_secure.a:*
        ) *(.data*)
	_data_dst_end_ns = .;
    } > RAM_NS AT > FLASH_NS

    _data_src_start_ns = LOADADDR(.data.nonsecure);

    .bss.nonsecure (NOLOAD) :
    {
	_bss_dst_start_ns = .;
        EXCLUDE_FILE(
            */libnexus_boot_secure.a:*
            */libnexus_security.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_bsp_*_secure.a:*
            */libnexus_app_secure.a:*
        ) *(.bss*)
	*(COMMON)
	_bss_dst_end_ns = .;
    } > RAM_NS

    _bss_src_start_ns = LOADADDR(.bss.nonsecure);

    /DISCARD/ :
    {
	*(.comment)
	*(.note*)
	*(.eh_frame*)
    }
}
