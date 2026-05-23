# Secure-world module aggregation.
#
# This directory is only part of the build for boards that enable TrustZone or a
# comparable secure-world split. It composes secure services, the selected secure
# architecture backend, the selected secure BSP, and the secure boot code into a
# single interface library consumed by the final firmware target.
if(NOT NEXUS_ENABLE_SECURE_WORLD)
    message(FATAL_ERROR "secure/ should only be added when NEXUS_ENABLE_SECURE_WORLD is enabled")
endif()

# Build secure components in dependency order: services provide APIs, the
# architecture backend depends on BSP board data, the BSP is board-selected, and
# boot ties the layers together.
add_subdirectory(security)
add_subdirectory(drivers)
add_subdirectory(
    ${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_SECURE_ARCH_DIR}
    ${CMAKE_BINARY_DIR}/${NEXUS_BOARD_SECURE_ARCH_DIR}
)
add_subdirectory(bsp/${NEXUS_BOARD})
add_subdirectory(boot)

# Aggregate all secure-side modules for the final firmware link.
add_library(nexus_secure INTERFACE)
target_link_libraries(nexus_secure INTERFACE
    nexus_secure_services
    nexus_secure_drivers
    nexus_secure_arch
    nexus_secure_bsp
    nexus_secure_boot
)
