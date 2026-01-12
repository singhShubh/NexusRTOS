add_subdirectory(audio)
add_subdirectory(dma)
add_subdirectory(timer)
add_subdirectory(uart)

add_library(nexus_drivers INTERFACE)
target_link_libraries(nexus_drivers INTERFACE
    nexus_driver_audio
    nexus_driver_dma
    nexus_driver_timer
    nexus_driver_uart
)
