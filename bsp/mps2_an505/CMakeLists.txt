include(${CMAKE_SOURCE_DIR}/build/cmake/NexusModule.cmake)

# Public board face: only exported board constants.
nexus_add_interface_module(nexus_bsp_public
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC_DEPS
        nexus_project_options
)

# Board-private secure implementation.
nexus_add_static_module(nexus_bsp_mps2_an505_secure
    SOURCES
        secure/src/board_boot.c
        secure/src/board_early_init.c
        config/board_irq_table.c
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/inc
        ${CMAKE_CURRENT_SOURCE_DIR}/secure/src
    PUBLIC_DEPS
        nexus_bsp_public
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_SECURE=1
)

# Board-private non-secure implementation.
nexus_add_static_module(nexus_bsp_mps2_an505_nonsecure
    SOURCES
        nonsecure/src/board_nonsecure.c
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/inc
        ${CMAKE_CURRENT_SOURCE_DIR}/nonsecure/src
    PUBLIC_DEPS
        nexus_bsp_public
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_NONSECURE=1
)

add_library(nexus_bsp INTERFACE)
target_link_libraries(nexus_bsp INTERFACE
    nexus_bsp_public
    nexus_bsp_mps2_an505_secure
    nexus_bsp_mps2_an505_nonsecure
)
