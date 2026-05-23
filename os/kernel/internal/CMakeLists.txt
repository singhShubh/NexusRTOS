# Kernel-internal API headers exported only to kernel implementation modules.
nexus_add_interface_module(nexus_kernel_internal_api
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)
