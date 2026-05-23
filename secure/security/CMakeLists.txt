# Secure services module.
#
# Owns initialization for secure-only services and future non-secure callable
# gateways. The public include directory exposes only the service init API.
nexus_add_static_module(nexus_secure_services
    SOURCES
        src/secure_services.c
    PUBLIC_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    PRIVATE_DEPS
        nexus_project_options
    COMPILE_DEFINITIONS
        NEXUS_WORLD_SECURE=1
)
