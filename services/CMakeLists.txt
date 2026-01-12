add_subdirectory(audio)
add_subdirectory(logging)
add_subdirectory(shell)

add_library(nexus_services INTERFACE)
target_link_libraries(nexus_services INTERFACE
    nexus_service_audio
    nexus_service_logging
    nexus_service_shell
)
