add_subdirectory(secure)
add_subdirectory(nonsecure)

add_library(nexus_boot INTERFACE)
target_link_libraries(nexus_boot INTERFACE
    nexus_boot_secure
    nexus_boot_nonsecure
)
