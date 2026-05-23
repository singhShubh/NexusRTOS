# Secure-world security controller driver aggregation.
#
# Concrete reusable security-controller implementations live in provider-specific
# subdirectories. Board policy remains in secure/bsp/<board> and should depend on
# the relevant implementation target when it starts programming MPC/PPC policy.
add_subdirectory(sie200)

add_library(nexus_secure_drivers_security INTERFACE)
target_link_libraries(nexus_secure_drivers_security INTERFACE
    nexus_secure_drivers_security_sie200
)
