add_subdirectory(secure)
add_subdirectory(nonsecure)

add_library(nexus_arch INTERFACE)
target_link_libraries(nexus_arch INTERFACE
    nexus_arch_cortex_m33_secure
    nexus_arch_cortex_m33_nonsecure
)
