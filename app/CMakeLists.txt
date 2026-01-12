add_subdirectory(secure)
add_subdirectory(nonsecure)

add_library(nexus_app INTERFACE)
target_link_libraries(nexus_app INTERFACE
    nexus_app_secure
    nexus_app_nonsecure
)
