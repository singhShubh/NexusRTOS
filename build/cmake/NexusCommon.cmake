function(nexus_enforce_out_of_source)
    if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
        message(FATAL_ERROR "In-source builds are disabled. Use -B build/<board>/<BuildType>")
    endif()
endfunction()

function(nexus_enforce_board_build_dir board_name)
    set(_expected_prefix "${CMAKE_SOURCE_DIR}/build/${board_name}")
    cmake_path(NORMAL_PATH _expected_prefix)

    set(_actual_binary_dir "${CMAKE_BINARY_DIR}")
    cmake_path(NORMAL_PATH _actual_binary_dir)

    cmake_path(IS_PREFIX _expected_prefix "${_actual_binary_dir}" NORMALIZE _is_valid_board_build_dir)
    if(NOT _is_valid_board_build_dir)
        message(FATAL_ERROR
            "Build directory must be under '${_expected_prefix}'. "
            "Use -B build/${board_name}/<BuildType> instead of '${_actual_binary_dir}'.")
    endif()
endfunction()

function(nexus_set_default_build_type default_type)
    if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "${default_type}" CACHE STRING "Build type" FORCE)
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release)
    endif()
endfunction()

function(nexus_set_output_dirs)
    set(NEXUS_ARTIFACT_DIR  "${CMAKE_BINARY_DIR}/artifacts" PARENT_SCOPE)
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/generated")
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/artifacts")
endfunction()
