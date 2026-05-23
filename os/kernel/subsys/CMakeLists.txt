# Kernel subsystems composed from independent modules.
add_subdirectory(workqueue)
add_subdirectory(timer)

# Subsystem aggregator linked by the kernel implementation target.
add_library(nexus_kernel_subsys INTERFACE)
target_link_libraries(nexus_kernel_subsys INTERFACE
    nexus_kernel_subsys_workqueue
    nexus_kernel_subsys_timer
)
