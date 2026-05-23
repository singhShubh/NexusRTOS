# Kernel workqueue subsystem implementation module.
nexus_add_static_module(nexus_kernel_subsys_workqueue
    SOURCES
        src/nexus_workqueue.c
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC_DEPS
        nexus_kernel_internal_api
        nexus_kernel_core
        nexus_kernel_sched
        nexus_kernel_irq
    PRIVATE_DEPS
        nexus_project_options
)
