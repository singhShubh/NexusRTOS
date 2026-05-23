# Portenta C33 secure BSP scaffold.
#
# The board currently has only placeholder secure initialization. The target is
# structured like other secure BSPs so it can grow into the common
# nexus_secure_bsp API without changing secure boot.
set(NEXUS_SECURE_BSP_PORTENTA_C33_SOURCES
    src/board_early_init.c
    ${CMAKE_SOURCE_DIR}/bsp/common/src/board_irq_table.c
)

nexus_add_static_module(nexus_secure_bsp_portenta_c33
    SOURCES
        ${NEXUS_SECURE_BSP_PORTENTA_C33_SOURCES}
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_SOURCE_DIR}/secure/bsp/include
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_SECURE=1
)

add_library(nexus_secure_bsp INTERFACE)
target_link_libraries(nexus_secure_bsp INTERFACE
    nexus_secure_bsp_portenta_c33
)
