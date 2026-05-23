# Secure-world reusable driver aggregation.
#
# Drivers under this tree provide reusable secure-side hardware helpers shared by
# board BSPs. Board-specific policy and address maps remain in secure/bsp/<board>.
add_subdirectory(security)

add_library(nexus_secure_drivers INTERFACE)
target_link_libraries(nexus_secure_drivers INTERFACE
    nexus_secure_drivers_security
)
