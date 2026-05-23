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
        */libnexus_secure_boot.a:*(.text .text.*)
        */libnexus_secure_services.a:*(.text .text.*)
        */libnexus_arch_*_secure.a:*(.text .text.*)
        */libnexus_secure_bsp_*.a:*(.text .text.*)
    } > FLASH_S

    .text.nonsecure :
    {
        KEEP(*(.vector_table_nonsecure))
        KEEP(*(.isr_vector_nonsecure))
        EXCLUDE_FILE(
            */libnexus_secure_boot.a:*
            */libnexus_secure_services.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_secure_bsp_*.a:*
        ) *(.text*)
    } > FLASH_NS

    .rodata.secure :
    {
        */libnexus_secure_boot.a:*(.rodata .rodata.*)
        */libnexus_secure_services.a:*(.rodata .rodata.*)
        */libnexus_arch_*_secure.a:*(.rodata .rodata.*)
        */libnexus_secure_bsp_*.a:*(.rodata .rodata.*)
    } > FLASH_S

    .rodata.nonsecure :
    {
        EXCLUDE_FILE(
            */libnexus_secure_boot.a:*
            */libnexus_secure_services.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_secure_bsp_*.a:*
        ) *(.rodata*)
    } > FLASH_NS

    .data.secure :
    {
        */libnexus_secure_boot.a:*(.data .data.*)
        */libnexus_secure_services.a:*(.data .data.*)
        */libnexus_arch_*_secure.a:*(.data .data.*)
        */libnexus_secure_bsp_*.a:*(.data .data.*)
    } > RAM_S AT > FLASH_S

    .data.nonsecure :
    {
        EXCLUDE_FILE(
            */libnexus_secure_boot.a:*
            */libnexus_secure_services.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_secure_bsp_*.a:*
        ) *(.data*)
    } > RAM_NS AT > FLASH_NS

    .bss.secure (NOLOAD) :
    {
        */libnexus_secure_boot.a:*(.bss .bss.*)
        */libnexus_secure_services.a:*(.bss .bss.*)
        */libnexus_arch_*_secure.a:*(.bss .bss.*)
        */libnexus_secure_bsp_*.a:*(.bss .bss.*)
        *(COMMON)
    } > RAM_S

    .bss.nonsecure (NOLOAD) :
    {
        EXCLUDE_FILE(
            */libnexus_secure_boot.a:*
            */libnexus_secure_services.a:*
            */libnexus_arch_*_secure.a:*
            */libnexus_secure_bsp_*.a:*
        ) *(.bss*)
        *(COMMON)
    } > RAM_NS

    /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}
