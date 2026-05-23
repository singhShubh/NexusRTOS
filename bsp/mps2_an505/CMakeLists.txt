# Public board interface exposed to dependent modules.
nexus_add_interface_module(nexus_bsp_public
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC_DEPS
        nexus_project_options
)

# Non-secure BSP implementation sources.
set(NEXUS_BSP_MPS2_AN505_NONSECURE_SOURCES
    src/board_nonsecure.c
)

# Board-specific non-secure implementation module.
nexus_add_static_module(nexus_bsp_mps2_an505_nonsecure
    SOURCES
        ${NEXUS_BSP_MPS2_AN505_NONSECURE_SOURCES}
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC_DEPS
        nexus_bsp_public
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_NONSECURE=1
)

# Unified non-secure BSP dependency target consumed by top-level build targets.
add_library(nexus_bsp INTERFACE)
target_link_libraries(nexus_bsp INTERFACE
    nexus_bsp_public
    nexus_bsp_mps2_an505_nonsecure
)
