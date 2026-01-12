# nexus_configure_board_irqs(board_name source_config_dir)
#
# Reads NEXUS_BOARD_IRQ_LIST from the calling scope — a CMake list where each
# element encodes one IRQ as a semicolon-free record using the separator "|":
#
#   "<irq_n>|<name>|<world>|<priority>"
#
#   irq_n    : integer CMSIS IRQn (e.g. 0, 5, -1 for hard fault etc.)
#   name     : string identifier used in the struct and for diagnostics
#   world    : SECURE or NONSECURE
#   priority : decimal NVIC priority value
#
# Example entry in board_resources.cmake:
#   list(APPEND NEXUS_BOARD_IRQ_LIST "0|TIMER0_IRQ|SECURE|2")
#
# The function generates into ${CMAKE_BINARY_DIR}/generated/bsp/<board>/config/:
#   board_irq_map.h    — extern table declaration + count macro
#   board_irq_table.c  — table definition, added to the secure BSP sources
#
# It sets in PARENT_SCOPE:
#   NEXUS_BOARD_IRQ_MAP_H     — path to generated header
#   NEXUS_BOARD_IRQ_TABLE_C   — path to generated C source
#
function(nexus_configure_board_irqs board_name source_config_dir)
    if(NOT DEFINED NEXUS_BOARD_IRQ_LIST)
        message(FATAL_ERROR
            "nexus_configure_board_irqs: NEXUS_BOARD_IRQ_LIST must be set before calling this function")
    endif()

    set(_generated_dir "${CMAKE_BINARY_DIR}/generated/bsp/${board_name}/config")
    file(MAKE_DIRECTORY "${_generated_dir}")

    list(LENGTH NEXUS_BOARD_IRQ_LIST NEXUS_BOARD_IRQ_COUNT)

    set(_entries "")
    foreach(_record IN LISTS NEXUS_BOARD_IRQ_LIST)
        string(REPLACE "|" ";" _fields "${_record}")
        list(GET _fields 0 _irq_n)
        list(GET _fields 1 _name)
        list(GET _fields 2 _world)
        list(GET _fields 3 _priority)

        if(_world STREQUAL "SECURE")
            set(_world_val "NEXUS_IRQ_DOMAIN_SECURE")
        elseif(_world STREQUAL "NONSECURE")
            set(_world_val "NEXUS_IRQ_DOMAIN_NONSECURE")
        else()
            message(FATAL_ERROR
                "nexus_configure_board_irqs: unknown world '${_world}' in IRQ '${_name}'."
                " Must be SECURE or NONSECURE")
        endif()

        string(APPEND _entries
            "    { .irq_n = ${_irq_n}, .name = \"${_name}\", .domain = ${_world_val}, .priority = ${_priority}U },\n")
    endforeach()

    set(NEXUS_BOARD_IRQ_TABLE_ENTRIES "${_entries}")

    configure_file(
        "${source_config_dir}/board_irq_map.h.in"
        "${_generated_dir}/board_irq_map.h"
        @ONLY
    )

    configure_file(
        "${source_config_dir}/board_irq_table.c.in"
        "${_generated_dir}/board_irq_table.c"
        @ONLY
    )

    set(NEXUS_BOARD_IRQ_MAP_H   "${_generated_dir}/board_irq_map.h"   PARENT_SCOPE)
    set(NEXUS_BOARD_IRQ_TABLE_C "${_generated_dir}/board_irq_table.c" PARENT_SCOPE)
endfunction()

function(nexus_list_boards out_var)
    set(_boards)
    file(GLOB _candidate_files RELATIVE "${CMAKE_SOURCE_DIR}" "bsp/*/config/*.cmake")
    foreach(_candidate IN LISTS _candidate_files)
        get_filename_component(_cfg_name "${_candidate}" NAME_WE)
        get_filename_component(_cfg_dir  "${CMAKE_SOURCE_DIR}/${_candidate}" DIRECTORY)
        get_filename_component(_board_dir "${_cfg_dir}" DIRECTORY)
        get_filename_component(_board_name "${_board_dir}" NAME)
        if(_cfg_name STREQUAL _board_name)
            list(APPEND _boards "${_board_name}")
        endif()
    endforeach()
    list(REMOVE_DUPLICATES _boards)
    list(SORT _boards)
    set(${out_var} "${_boards}" PARENT_SCOPE)
endfunction()

function(nexus_configure_board_resources board_name source_config_dir)
    if(NOT board_name)
        message(FATAL_ERROR "nexus_configure_board_resources requires board_name")
    endif()
    if(NOT source_config_dir)
        message(FATAL_ERROR "nexus_configure_board_resources requires source_config_dir")
    endif()

    set(_generated_config_dir "${CMAKE_BINARY_DIR}/generated/bsp/${board_name}/config")
    file(MAKE_DIRECTORY "${_generated_config_dir}")

    configure_file(
        "${source_config_dir}/memory_map.h"
        "${_generated_config_dir}/memory_map.h"
        @ONLY
    )

    configure_file(
        "${source_config_dir}/linker_unified.ld"
        "${_generated_config_dir}/linker_unified.ld"
        @ONLY
    )

    set(_board_include_dirs ${_generated_config_dir})
    if(ARGN)
        list(APPEND _board_include_dirs ${ARGN})
    endif()

    set(NEXUS_BOARD_GENERATED_CONFIG_DIR "${_generated_config_dir}" PARENT_SCOPE)
    set(NEXUS_BOARD_LINKER_SCRIPT "${_generated_config_dir}/linker_unified.ld" PARENT_SCOPE)
    set(NEXUS_BOARD_INCLUDE_DIRS ${_board_include_dirs} PARENT_SCOPE)
endfunction()

function(nexus_load_board board_name)
    set(_cfg "${CMAKE_SOURCE_DIR}/bsp/${board_name}/config/${board_name}.cmake")
    if(NOT EXISTS "${_cfg}")
        nexus_list_boards(_boards)
        message(FATAL_ERROR "Unknown board '${board_name}'. Available boards: ${_boards}")
    endif()

    include("${_cfg}")

    set(NEXUS_BOARD_ARCH_DIR "arch/${NEXUS_BOARD_ARCH}/${NEXUS_BOARD_CPU}")
    set(NEXUS_BOARD_ARCH_CONFIG "${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_ARCH_DIR}/arch.cmake")

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
    set(NEXUS_BOARD_ARCH_DIR      "${NEXUS_BOARD_ARCH_DIR}"      PARENT_SCOPE)
    set(NEXUS_BOARD_ARCH_CONFIG   "${NEXUS_BOARD_ARCH_CONFIG}"   PARENT_SCOPE)
    set(NEXUS_BOARD_LINKER_SCRIPT "${NEXUS_BOARD_LINKER_SCRIPT}" PARENT_SCOPE)
    set(NEXUS_BOARD_CPU_FLAGS     "${NEXUS_BOARD_CPU_FLAGS}"     PARENT_SCOPE)
    set(NEXUS_BOARD_INCLUDE_DIRS  "${NEXUS_BOARD_INCLUDE_DIRS}"  PARENT_SCOPE)
endfunction()
