ENTRY(nexus_dummy_entry)

MEMORY
{
    FLASH_S  (rx)  : ORIGIN = 0x08000000,  LENGTH = 0x00040000
    FLASH_NS (rx)  : ORIGIN = 0x08040000, LENGTH = 0x00040000
    RAM_S    (rwx) : ORIGIN = 0x20000000,    LENGTH = 0x00010000
    RAM_NS   (rwx) : ORIGIN = 0x20010000,   LENGTH = 0x00010000
}

SECTIONS
{
    /*
     * World routing policy:
     * - Secure regions pull sections from secure-target archives.
     * - Non-secure regions pull everything else, excluding secure archives.
     */

    .text.secure :
    {
        KEEP(*(.vector_table_secure))
        KEEP(*(.isr_vector_secure))
        */libnexus_boot_secure.a:*(.text .text.*)
        */libnexus_security.a:*(.text .text.*)
        */libnexus_arch_*_secure.a:*(.text .text.*)
        */libnexus_bsp_*_secure.a:*(.text .text.*)
        */libnexus_app_secure.a:*(.text .text.*)
    } > FLASH_S

    .text.nonsecure :
    {
        KEEP(*(.vector_table_nonsecure))
        KEEP(*(.isr_vector_nonsecure))
        EXCLUDE_FILE(
            */libnexus_boot_secure.a:*
            */libnexus_security.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_bsp_*_secure.a:*
            */libnexus_app_secure.a:*
        ) *(.text*)
    } > FLASH_NS

    .rodata.secure :
    {
        */libnexus_boot_secure.a:*(.rodata .rodata.*)
        */libnexus_security.a:*(.rodata .rodata.*)
        */libnexus_arch_*_secure.a:*(.rodata .rodata.*)
        */libnexus_bsp_*_secure.a:*(.rodata .rodata.*)
        */libnexus_app_secure.a:*(.rodata .rodata.*)
    } > FLASH_S

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

    .data.secure :
    {
        */libnexus_boot_secure.a:*(.data .data.*)
        */libnexus_security.a:*(.data .data.*)
        */libnexus_arch_*_secure.a:*(.data .data.*)
        */libnexus_bsp_*_secure.a:*(.data .data.*)
        */libnexus_app_secure.a:*(.data .data.*)
    } > RAM_S AT > FLASH_S

    .data.nonsecure :
    {
        EXCLUDE_FILE(
            */libnexus_boot_secure.a:*
            */libnexus_security.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_bsp_*_secure.a:*
            */libnexus_app_secure.a:*
        ) *(.data*)
    } > RAM_NS AT > FLASH_NS

    .bss.secure (NOLOAD) :
    {
        */libnexus_boot_secure.a:*(.bss .bss.*)
        */libnexus_security.a:*(.bss .bss.*)
        */libnexus_arch_*_secure.a:*(.bss .bss.*)
        */libnexus_bsp_*_secure.a:*(.bss .bss.*)
        */libnexus_app_secure.a:*(.bss .bss.*)
        *(COMMON)
    } > RAM_S

    .bss.nonsecure (NOLOAD) :
    {
        EXCLUDE_FILE(
            */libnexus_boot_secure.a:*
            */libnexus_security.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_bsp_*_secure.a:*
            */libnexus_app_secure.a:*
        ) *(.bss*)
        *(COMMON)
    } > RAM_NS

    /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}
