# Kernel module composition.
add_subdirectory(internal)
add_subdirectory(core)
add_subdirectory(sched)
add_subdirectory(task)
add_subdirectory(irq)
add_subdirectory(mem)
add_subdirectory(ipc)
add_subdirectory(subsys)

# Public kernel API surface available to higher layers.
add_library(nexus_kernel INTERFACE)

# Internal kernel implementation aggregator linked into the final image.
add_library(nexus_kernel_impl INTERFACE)
target_link_libraries(nexus_kernel_impl INTERFACE
    nexus_kernel_core
    nexus_kernel_sched
    nexus_kernel_task
    nexus_kernel_irq
    nexus_kernel_mem
    nexus_kernel_ipc
    nexus_kernel_subsys
)
