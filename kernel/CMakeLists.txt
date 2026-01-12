add_subdirectory(api)
add_subdirectory(internal)
add_subdirectory(core)
add_subdirectory(sched)
add_subdirectory(task)
add_subdirectory(irq)
add_subdirectory(mem)
add_subdirectory(ipc)
add_subdirectory(subsys)
add_subdirectory(syscall)

# Public kernel face available to drivers, services, and applications.
add_library(nexus_kernel INTERFACE)
target_link_libraries(nexus_kernel INTERFACE
    nexus_kernel_api
)

# Internal implementation aggregator used by the final image.
add_library(nexus_kernel_impl INTERFACE)
target_link_libraries(nexus_kernel_impl INTERFACE
    nexus_kernel_core
    nexus_kernel_sched
    nexus_kernel_task
    nexus_kernel_irq
    nexus_kernel_mem
    nexus_kernel_ipc
    nexus_kernel_subsys
    nexus_kernel_syscall
)
