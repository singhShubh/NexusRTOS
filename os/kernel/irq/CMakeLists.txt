# Kernel interrupt management implementation module.
nexus_add_static_module(nexus_kernel_irq
    SOURCES
        src/nexus_irq.c
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC_DEPS
        nexus_kernel_internal_api
        nexus_kernel_core
    PRIVATE_DEPS
        nexus_project_options
)
