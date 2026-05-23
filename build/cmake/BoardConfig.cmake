function(nexus_list_boards out_var)
    set(_boards)
    file(GLOB _candidate_files RELATIVE "${CMAKE_SOURCE_DIR}" "bsp_config/*/*.cmake")
    foreach(_candidate IN LISTS _candidate_files)
        get_filename_component(_cfg_name "${_candidate}" NAME_WE)
        get_filename_component(_cfg_dir "${CMAKE_SOURCE_DIR}/${_candidate}" DIRECTORY)
        get_filename_component(_board_name "${_cfg_dir}" NAME)
        if(_cfg_name STREQUAL _board_name)
            list(APPEND _boards "${_board_name}")
        endif()
    endforeach()
    list(REMOVE_DUPLICATES _boards)
    list(SORT _boards)
    set(${out_var} "${_boards}" PARENT_SCOPE)
endfunction()

function(nexus_load_board board_name)
    set(_board_config "${CMAKE_SOURCE_DIR}/bsp_config/${board_name}/${board_name}.cmake")
    if(NOT EXISTS "${_board_config}")
        nexus_list_boards(_boards)
        message(FATAL_ERROR "Unknown board '${board_name}'. Available boards: ${_boards}")
    endif()

    include("${_board_config}")

    set(NEXUS_BOARD_ARCH_DIR "os/arch/${NEXUS_BOARD_ARCH}/${NEXUS_BOARD_CPU}")
    set(NEXUS_BOARD_ARCH_COMMON_DIR "os/arch/${NEXUS_BOARD_ARCH}/common")
    set(NEXUS_BOARD_SECURE_ARCH_DIR "secure/arch/${NEXUS_BOARD_ARCH}/${NEXUS_BOARD_CPU}")
    set(NEXUS_BOARD_ARCH_CONFIG "${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_ARCH_DIR}/arch.cmake")

    set(_secure_default OFF)
    if(EXISTS "${CMAKE_SOURCE_DIR}/secure/bsp/${board_name}/CMakeLists.txt"
       AND EXISTS "${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_SECURE_ARCH_DIR}/CMakeLists.txt")
        set(_secure_default ON)
    endif()

    if(DEFINED NEXUS_BOARD_ENABLE_SECURE_WORLD)
        set(_secure_enabled "${NEXUS_BOARD_ENABLE_SECURE_WORLD}")
    else()
        set(_secure_enabled "${_secure_default}")
    endif()
    if(_secure_enabled)
        set(_secure_enabled ON)
    else()
        set(_secure_enabled OFF)
    endif()

    foreach(_required_var IN ITEMS
        NEXUS_BOARD_ARCH
        NEXUS_BOARD_CPU
        NEXUS_BOARD_LINKER_SCRIPT
        NEXUS_BOARD_CPU_FLAGS
        NEXUS_BOARD_INCLUDE_DIRS)
        if(NOT DEFINED ${_required_var})
            message(FATAL_ERROR "Board '${board_name}' did not define required variable: ${_required_var}")
        endif()
    endforeach()

    set(NEXUS_BOARD_ARCH          "${NEXUS_BOARD_ARCH}"          PARENT_SCOPE)
    set(NEXUS_BOARD_CPU           "${NEXUS_BOARD_CPU}"           PARENT_SCOPE)
    set(NEXUS_BOARD_ENABLE_SECURE_WORLD "${_secure_enabled}" PARENT_SCOPE)
    set(NEXUS_BOARD_ARCH_DIR      "${NEXUS_BOARD_ARCH_DIR}"      PARENT_SCOPE)
    set(NEXUS_BOARD_ARCH_COMMON_DIR "${NEXUS_BOARD_ARCH_COMMON_DIR}" PARENT_SCOPE)
    set(NEXUS_BOARD_SECURE_ARCH_DIR "${NEXUS_BOARD_SECURE_ARCH_DIR}" PARENT_SCOPE)
    set(NEXUS_BOARD_ARCH_CONFIG   "${NEXUS_BOARD_ARCH_CONFIG}"   PARENT_SCOPE)
    set(NEXUS_BOARD_LINKER_SCRIPT "${NEXUS_BOARD_LINKER_SCRIPT}" PARENT_SCOPE)
    set(NEXUS_BOARD_CPU_FLAGS     "${NEXUS_BOARD_CPU_FLAGS}"     PARENT_SCOPE)
    set(NEXUS_BOARD_INCLUDE_DIRS  "${NEXUS_BOARD_INCLUDE_DIRS}"  PARENT_SCOPE)
endfunction()
