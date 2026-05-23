# MPS2+ AN505 secure BSP.
#
# Provides the secure board API implementation, AN505 interrupt ownership table,
# and the secure startup vector used before C runtime initialization.
set(NEXUS_SECURE_BSP_MPS2_AN505_STARTUP_SOURCES
    src/startup.S
)

set(NEXUS_SECURE_BSP_MPS2_AN505_SOURCES
    src/board_init.c
    src/board_irq_table.c
)

# Startup is kept as an object library so its vector-table object is linked into
# the final firmware without exposing it as a callable module.
add_library(nexus_secure_bsp_mps2_an505_startup OBJECT
    ${NEXUS_SECURE_BSP_MPS2_AN505_STARTUP_SOURCES}
)
target_link_libraries(nexus_secure_bsp_mps2_an505_startup
    PRIVATE
        nexus_project_options
)
target_include_directories(nexus_secure_bsp_mps2_an505_startup
    PRIVATE
        ${CMAKE_SOURCE_DIR}/secure/bsp/include
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)
target_compile_definitions(nexus_secure_bsp_mps2_an505_startup
    PRIVATE
        NEXUS_WORLD_SECURE=1
)

nexus_add_static_module(nexus_secure_bsp_mps2_an505
    SOURCES
        ${NEXUS_SECURE_BSP_MPS2_AN505_SOURCES}
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_SOURCE_DIR}/secure/bsp/include
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC_DEPS
        # No public dependencies beyond project include paths today.
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_SECURE=1
)

# Board-independent alias consumed by secure boot and architecture code.
add_library(nexus_secure_bsp INTERFACE)
target_link_libraries(nexus_secure_bsp INTERFACE
    nexus_secure_bsp_mps2_an505
)
target_sources(nexus_secure_bsp INTERFACE
    $<TARGET_OBJECTS:nexus_secure_bsp_mps2_an505_startup>
)
