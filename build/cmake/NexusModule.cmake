include(CMakeParseArguments)

# Leaf static module with explicit public/private headers and deps.
function(nexus_add_static_module target)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs
        SOURCES
        PUBLIC_INCLUDE_DIRS
        PRIVATE_INCLUDE_DIRS
        PUBLIC_DEPS
        PRIVATE_DEPS
        COMPILE_DEFINITIONS
        COMPILE_OPTIONS)

    cmake_parse_arguments(NXM "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    add_library(${target} STATIC ${NXM_SOURCES})
    target_link_libraries(${target}
        PUBLIC  ${NXM_PUBLIC_DEPS}
        PRIVATE ${NXM_PRIVATE_DEPS}
    )
    if(NXM_PUBLIC_INCLUDE_DIRS OR NXM_PRIVATE_INCLUDE_DIRS)
        target_include_directories(${target}
            PUBLIC  ${NXM_PUBLIC_INCLUDE_DIRS}
            PRIVATE ${NXM_PRIVATE_INCLUDE_DIRS}
        )
    endif()
    if(NXM_COMPILE_DEFINITIONS)
        target_compile_definitions(${target} PRIVATE ${NXM_COMPILE_DEFINITIONS})
    endif()
    if(NXM_COMPILE_OPTIONS)
        target_compile_options(${target} PRIVATE ${NXM_COMPILE_OPTIONS})
    endif()
endfunction()

# Pure interface/API module used to export public include dirs and transitive dependencies.
function(nexus_add_interface_module target)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs
        PUBLIC_INCLUDE_DIRS
        PUBLIC_DEPS)

    cmake_parse_arguments(NXM "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    add_library(${target} INTERFACE)
    if(NXM_PUBLIC_INCLUDE_DIRS)
        target_include_directories(${target} INTERFACE ${NXM_PUBLIC_INCLUDE_DIRS})
    endif()
    if(NXM_PUBLIC_DEPS)
        target_link_libraries(${target} INTERFACE ${NXM_PUBLIC_DEPS})
    endif()
endfunction()
