set(NEXUS_BOOT_SECURE_SOURCES
    src/reset_entry.c
    src/early_boot.c
    src/boot_panic.c
)

if(EXISTS "${CMAKE_SOURCE_DIR}/bsp/${NEXUS_BOARD}/secure/src/startup.S")
    list(APPEND NEXUS_BOOT_SECURE_SOURCES
        ${CMAKE_SOURCE_DIR}/bsp/${NEXUS_BOARD}/secure/src/startup.S
    )
endif()

nexus_add_static_module(nexus_boot_secure
    SOURCES
        ${NEXUS_BOOT_SECURE_SOURCES}
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC_DEPS
        nexus_security
        nexus_arch
        nexus_bsp
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_SECURE=1
)
