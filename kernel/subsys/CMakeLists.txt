add_subdirectory(workqueue)
add_subdirectory(timer)
add_subdirectory(dma)

add_library(nexus_kernel_subsys INTERFACE)
target_link_libraries(nexus_kernel_subsys INTERFACE
    nexus_kernel_subsys_workqueue
    nexus_kernel_subsys_timer
    nexus_kernel_subsys_dma
)
