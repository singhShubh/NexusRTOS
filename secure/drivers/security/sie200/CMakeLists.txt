# Arm SIE-200 secure-world security controller driver skeletons.
#
# Provides reusable MPC/PPC register models and helper APIs for boards using the
# SIE-200 security subsystem. Concrete board access policy remains in the secure
# BSP layer.
set(NEXUS_SECURE_SECURITY_SIE200_DRIVER_SOURCES
    src/sie200_mpc.c
    src/sie200_ppc.c
)

nexus_add_static_module(nexus_secure_drivers_security_sie200
    SOURCES
        ${NEXUS_SECURE_SECURITY_SIE200_DRIVER_SOURCES}
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/inc
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_SECURE=1
)
