# Secure boot module.
#
# Contains the secure reset handler, minimal C runtime setup, and boot phase
# orchestration. It depends on public BSP/arch/service APIs rather than on
# board- or CPU-specific private headers.
set(NEXUS_SECURE_BOOT_SOURCES
    src/reset_entry.c
    src/secure_boot.c
    src/boot_panic.c
)

nexus_add_static_module(nexus_secure_boot
    SOURCES
        ${NEXUS_SECURE_BOOT_SOURCES}
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC_DEPS
        nexus_secure_services
        nexus_secure_arch
        nexus_secure_bsp
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_SECURE=1
)
