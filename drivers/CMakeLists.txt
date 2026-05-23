# Driver module composition.
add_subdirectory(dma)
add_subdirectory(timer)
add_subdirectory(uart)

# Driver aggregator consumed by upper layers.
add_library(nexus_drivers INTERFACE)
target_link_libraries(nexus_drivers INTERFACE
    nexus_driver_dma
    nexus_driver_timer
    nexus_driver_uart
)
