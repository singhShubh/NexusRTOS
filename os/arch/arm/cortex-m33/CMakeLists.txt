# Architecture module.
nexus_add_static_module(nexus_arch_cortex_m33
    SOURCES
        src/nexus_asm.S
        src/nexus_exception.c
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC_DEPS
        nexus_project_options
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_NONSECURE=1
    # World-specific architecture compile options.
    COMPILE_OPTIONS
        ${NEXUS_ARCH_NONSECURE_COMPILE_FLAGS}
)

# Architecture aggregator consumed by other modules.
add_library(nexus_arch INTERFACE)
target_link_libraries(nexus_arch INTERFACE
    nexus_arch_cortex_m33
)
