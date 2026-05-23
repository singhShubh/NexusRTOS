# Cortex-M33 secure architecture backend.
#
# This module implements the generic secure architecture API from
# secure/arch/include for Cortex-M33 systems. Register definitions and internal
# init hooks stay private in inc/; boot only sees nexus_secure_arch_init().
nexus_add_static_module(nexus_secure_arch_cortex_m33
    SOURCES
        src/arch_secure_init.c
        src/arch_exceptions.c
        src/arch_irq.c
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_SOURCE_DIR}/secure/arch/include
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/inc
    PUBLIC_DEPS
        nexus_project_options
    PRIVATE_DEPS
        nexus_project_options
        nexus_secure_bsp
    COMPILE_DEFINITIONS
        NEXUS_WORLD_SECURE=1
    # TrustZone secure translation units require the CMSE code-generation mode.
    COMPILE_OPTIONS
        ${NEXUS_ARCH_SECURE_COMPILE_FLAGS}
        -mcmse
)

# Board-independent alias consumed by secure/ and the final firmware target.
add_library(nexus_secure_arch INTERFACE)
target_link_libraries(nexus_secure_arch INTERFACE
    nexus_secure_arch_cortex_m33
)
